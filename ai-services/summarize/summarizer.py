import os
from pathlib import Path
import re
import numpy as np
import pandas as pd
import ollama
from sentence_transformers import SentenceTransformer
import pypdf as PyPDF2  # Fixed naming and used pypdf

def read_file(file_path: Path) -> str:
    """Read file content from .txt or .pdf."""
    if file_path.suffix.lower() == ".txt":
        return file_path.read_text(encoding="utf-8")
    elif file_path.suffix.lower() == ".pdf":
        text = ""
        with file_path.open("rb") as f:
            reader = PyPDF2.PdfReader(f)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        return text
    else:
        raise ValueError(f"Unsupported file type: {file_path.suffix}")

def clean_text(text: str) -> str:
    """Remove common irrelevant sections."""
    match = re.search(r"(Bibliography|References)", text, re.IGNORECASE)
    return text[:match.start()] if match else text

def chunk_text(text: str, max_chunk_length: int = 2500) -> list:
    """Split text into chunks for processing."""
    paragraphs = text.split("\n")
    chunks = []
    current_chunk = ""
    for para in paragraphs:
        if len(current_chunk) + len(para) + 1 > max_chunk_length:
            chunks.append(current_chunk.strip())
            current_chunk = para + "\n"
        else:
            current_chunk += para + "\n"
    if current_chunk:
        chunks.append(current_chunk.strip())
    return chunks

def summarize_entire_document(document_text: str) -> str:
    """
    A General Solution: Processes every section of the PDF and combines
    them into one master summary.
    """
    cleaned_text = clean_text(document_text)
    # We use slightly smaller chunks to ensure the AI doesn't get overwhelmed
    chunks = chunk_text(cleaned_text, max_chunk_length=3000)
    print(f"Document split into {len(chunks)} chunks for full analysis.")

    section_summaries = []
    
    # 1. THE MAP PHASE: Summarize every part of the file
    # We take chunks in steps of 3 to ensure full coverage
    step = 3 
    for i in range(0, len(chunks), step):
        batch = chunks[i : i + step]
        context = "\n".join(batch)
        print(f"--- Summarizing Section {i//step + 1} of {(len(chunks)//step) + 1} ---")
        
        prompt = (
            f"Summarize this specific part of the document in detail, "
            f"capturing all technical terms and main arguments:\n\n{context}"
        )
        
        response = ollama.generate(model="gemma3:1b", prompt=prompt)
        section_summaries.append(response.get("response", ""))

    # 2. THE REDUCE PHASE: Combine all section summaries into one report
    print("--- Creating Final Master Report ---")
    master_context = "\n\n".join(section_summaries)
    
    final_prompt = (
        "You are an expert technical writer. Based on the following section-by-section summaries, "
        "write a comprehensive Final Report for the entire document. "
        "Structure it as follows:\n"
        "1. Executive Summary (Overall objective)\n"
        "2. Key Technical Sections (Detail every major topic mentioned)\n"
        "3. Conclusion/Takeaways\n\n"
        f"Summaries to synthesize:\n{master_context}"
    )

    final_response = ollama.generate(
        model="gemma3:1b", 
        prompt=final_prompt,
        options={"num_predict": 1500, "temperature": 0.4}
    )
    
    return final_response.get("response", "").strip()

def process_file(file_path: Path, output_folder: Path) -> tuple:
    """Read, process, and save results."""
    try:
        text = read_file(file_path)
        answer = summarize_entire_document(text)
        
        output_file = output_folder / f"{file_path.stem}_full_summary.txt"
        output_file.write_text(answer, encoding="utf-8")
        
        print(f"Final summary for {file_path.name} saved.")
        return file_path.name, answer
    except Exception as e:
        print(f"Error processing {file_path.name}: {e}")
        return None

def main():
    input_folder = Path("input")
    output_folder = Path("output_rag")
    input_folder.mkdir(exist_ok=True)
    output_folder.mkdir(exist_ok=True)

    # Use set() to avoid duplicates from .pdf and .PDF extensions
    raw_files = list(input_folder.glob("*.txt")) + \
                list(input_folder.glob("*.pdf")) + \
                list(input_folder.glob("*.PDF"))
    files = list(set(raw_files))

    if not files:
        print("No files found. Please put PDFs in the 'input' folder.")
        return

    results = []
    for file in files:
        print(f"\n>>> Starting Comprehensive Analysis: {file.name}")
        result = process_file(file, output_folder)
        if result:
            results.append(result)

    if results:
        df = pd.DataFrame(results, columns=["Filename", "Full Summary"])
        excel_path = output_folder / "final_reports.xlsx"
        df.to_excel(excel_path, index=False)
        print(f"\nAll reports saved to {excel_path}")

if __name__ == "__main__":
    main()