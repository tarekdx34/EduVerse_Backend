import re

from langchain_groq import ChatGroq
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

from app.core.config import MY_API_KEY


def format_standard_question(index: int, body: str) -> str:
    """Same display line for MCQ, FillBlank, and Explain: Question N: …"""
    text = (body or "").strip()
    # If the model left a nested "Question …:" at the start, strip one layer
    m = re.match(r"^\s*Question\s*\d*\s*:\s*", text, flags=re.IGNORECASE)
    if m:
        text = text[m.end() :].strip()
    return f"Question {index + 1}: {text}"

llm = ChatGroq(
    api_key=MY_API_KEY,
    model="llama-3.3-70b-versatile",
    temperature=0.0
)

mcq_prompt = PromptTemplate(
    input_variables=["context", "num_questions"],
    template="""
Generate {num_questions} multiple-choice questions from the following text. 
List all questions first, then provide a complete answer key at the end.

Text:
{context}

Format:
## MCQ Quiz
Question 1: [The question here]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]

Question 2: [The next question here]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]

...and so on for {num_questions} questions.

--- ANSWER KEY ---
Question 1: [The letter of the correct option]
Question 2: [The letter of the correct option]
...and so on.
"""
)

fill_blank_prompt = PromptTemplate(
    input_variables=["context", "num_questions"],
    template="""
Generate {num_questions} fill-in-the-blank questions from the following text.
List all questions first, then provide a complete answer key at the end.

Text:
{context}

Format:
## Fill in the Blank Quiz
Question 1: [A sentence with a _____ blank]
Question 2: [Another sentence with a _____ blank]
...and so on for {num_questions} questions.

--- ANSWER KEY ---
Question 1: [The word that fills the blank]
Question 2: [The word that fills the blank]
...and so on.
"""
)

explain_prompt = PromptTemplate(
    input_variables=["context", "num_questions"],
    template="""
Generate {num_questions} explanation questions from the following text. These should require a detailed answer.

Text:
{context}

Format (repeat this block exactly {num_questions} times, with Question 1, Question 2, …):
## Explanation Question
Question 1: [The question here]
Reference: [A relevant quote or fact from the text]

## Explanation Question
Question 2: [The next question here]
Reference: [A relevant quote or fact from the text]

…continue until you have {num_questions} "## Explanation Question" blocks.
Each question line must start with "Question N:" where N matches the block order (1, 2, 3, …).
"""
)

mcq_chain = mcq_prompt | llm | StrOutputParser()
fill_blank_chain = fill_blank_prompt | llm | StrOutputParser()
explain_chain = explain_prompt | llm | StrOutputParser()


def generate_quiz_from_text(text: str, num_questions: int, question_type: str, difficulty: str):
    final_questions = []
    answer_key = []
    raw_ai_output = ""

    if question_type == "MCQ":
        raw_ai_output = mcq_chain.invoke({"context": text, "num_questions": num_questions})
        if "--- ANSWER KEY ---" not in raw_ai_output:
            raise ValueError("AI did not provide a separate answer key.")

        questions_block, answers_block = raw_ai_output.split("--- ANSWER KEY ---")

        answers_map = {}
        for line in answers_block.strip().split('\n'):
            if ":" in line:
                q_id, answer = line.split(":", 1)
                answers_map[q_id.strip()] = answer.strip()

        question_chunks = questions_block.strip().split("Question")[1:]
        for i, chunk in enumerate(question_chunks):
            lines = chunk.strip().split('\n')
            stem = (
                lines[0].split(":", 1)[1].strip()
                if lines and ":" in lines[0]
                else (lines[0].strip() if lines else "")
            )
            question_text = format_standard_question(i, stem)

            options = []
            for line in lines[1:]:
                if line.startswith(("A)", "B)", "C)", "D)")):
                    options.append(line.strip())

            q_id = f"Question {i+1}"
            if question_text and options and q_id in answers_map:
                final_questions.append({
                    "type": "MCQ",
                    "difficulty": difficulty,
                    "question": question_text,
                    "options": options
                })
                answer_key.append({
                    "questionId": q_id,
                    "correctAnswer": answers_map[q_id]
                })

    elif question_type == "FillBlank":
        raw_ai_output = fill_blank_chain.invoke({"context": text, "num_questions": num_questions})
        if "--- ANSWER KEY ---" not in raw_ai_output:
            raise ValueError("AI did not provide a separate answer key.")

        questions_block, answers_block = raw_ai_output.split("--- ANSWER KEY ---")

        answers_map = {}
        for line in answers_block.strip().split('\n'):
            if ":" in line:
                q_id, answer = line.split(":", 1)
                answers_map[q_id.strip()] = answer.strip()

        question_chunks = questions_block.strip().split("Question")[1:]
        for i, chunk in enumerate(question_chunks):
            # Chunk may start with " 1: ..." after splitting on "Question"; strip that
            # number so we do not produce "Question 3: 3: ...".
            first_line = chunk.strip().split("\n", 1)[0]
            stem = first_line.split(":", 1)[1].strip() if ":" in first_line else first_line.strip()
            rest = chunk.strip().split("\n", 1)
            body = stem + ("\n" + rest[1] if len(rest) > 1 else "")
            question_text = format_standard_question(i, body)

            q_id = f"Question {i+1}"
            if question_text and q_id in answers_map:
                final_questions.append({
                    "type": "FillBlank",
                    "difficulty": difficulty,
                    "question": question_text
                })
                answer_key.append({
                    "questionId": q_id,
                    "answer": answers_map[q_id]
                })

    else:
        raw_ai_output = explain_chain.invoke({"context": text, "num_questions": num_questions})
        for i, item in enumerate(raw_ai_output.split("## Explanation Question")[1:]):
            lines = item.strip().split('\n')
            q_body = ""
            q_ref = ""
            for line in lines:
                s = line.strip()
                if s.startswith("Question") and ":" in s and not q_body:
                    q_body = s.split(":", 1)[1].strip()
                elif s.startswith("Reference:"):
                    q_ref = s.replace("Reference:", "").strip()

            if q_body:
                q_id = f"Question {i+1}"
                question_text = format_standard_question(i, q_body)
                final_questions.append({
                    "type": "Explain",
                    "difficulty": difficulty,
                    "question": question_text
                })
                answer_key.append({
                    "questionId": q_id,
                    "reference": q_ref
                })

    return final_questions, answer_key, raw_ai_output