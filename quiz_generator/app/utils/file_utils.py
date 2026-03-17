import os
import json
import logging
import pdfplumber
import docx
from fpdf import FPDF

def save_to_json(data, filename):
    try:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception as e:
        logging.error(f"Failed to save data to {filename}: {e}")

def load_from_json(filename, default_dict):
    if os.path.exists(filename):
        try:
            with open(filename, "r", encoding="utf-8") as f:
                loaded_data = json.load(f)
                default_dict.update(loaded_data)
        except Exception as e:
            logging.error(f"Could not load data from {filename}: {e}")
    return default_dict

def extract_text_from_file(file_path: str) -> str:
    ext = file_path.rsplit('.', 1)[-1].lower()
    if ext == "pdf":
        with pdfplumber.open(file_path) as pdf:
            return ''.join([p.extract_text() for p in pdf.pages if p.extract_text()])
    elif ext == "docx":
        doc = docx.Document(file_path)
        return ' '.join([para.text for para in doc.paragraphs])
    elif ext == "txt":
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    else:
        raise ValueError("Unsupported file type.")

def save_as_txt(content, filename, output_folder):
    path = os.path.join(output_folder, filename)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    return path

def save_as_pdf(content, filename, output_folder):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    for line in content.split('\n'):
        if line.strip():
            pdf.multi_cell(0, 10, line.strip())
            pdf.ln(2)
    path = os.path.join(output_folder, filename)
    pdf.output(path)
    return path