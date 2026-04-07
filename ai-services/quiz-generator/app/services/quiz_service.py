from langchain_groq import ChatGroq
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

from app.core.config import MY_API_KEY

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

Format:
## Explanation Question
Question: [The question here]
Reference: [A relevant quote or fact from the text]
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
            question_text = "Question " + str(i + 1) + ": " + lines[0].split(":", 1)[1].strip()

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
            question_text = "Question " + str(i + 1) + ": " + chunk.strip()

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
            q_data = {"type": "Explain", "difficulty": difficulty, "question": "", "reference": ""}
            for line in lines:
                if line.startswith("Question:"):
                    q_data["question"] = line.replace("Question:", "").strip()
                elif line.startswith("Reference:"):
                    q_data["reference"] = line.replace("Reference:", "").strip()

            if q_data["question"]:
                q_id = f"Question {i+1}"
                final_questions.append({
                    "type": "Explain",
                    "difficulty": difficulty,
                    "question": q_data["question"]
                })
                answer_key.append({
                    "questionId": q_id,
                    "reference": q_data["reference"]
                })

    return final_questions, answer_key, raw_ai_output