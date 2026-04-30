def mcq_from_text_prompt(count: int, difficulty: str, text: str) -> str:
    return f"""
Generate exactly {count} multiple-choice questions based ONLY on the text below.
Difficulty level: {difficulty}.
Rules:
- Do NOT use knowledge outside the text.
- Each question must test understanding of the content.
- Each question must have 4 options labeled A, B, C, D.
- Clearly mark the correct answer.
- Do NOT include explanations.
- Do NOT include commentary.
- Do NOT repeat questions.
- Return only the questions.


Text:
{text}
"""

def assistant_prompt(message: str) -> str:
    return f"""
    You are an academic assistant helping a university professor create exams.
    Provide structured, clear suggestions.

    Doctor request:
    {message}
    """

def extraction_prompt(example_text: str) -> str:
    return f"""
    You are extracting textbook examples.
    Extract ONLY ONE complete example that starts with the word "Example".

    Rules:
    - Start from the word "Example".
    - Stop when you reach:
     - the word "Solution"
     - OR a horizontal separator
     - OR text that clearly belongs to another column
   - Do NOT include side text.
   - Do NOT include solution unless explicitly part of the example.
   - Do NOT rewrite anything.
   - Return exactly as written.

    TEXT:
    {example_text}
    """

