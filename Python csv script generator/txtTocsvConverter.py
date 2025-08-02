import os
import pandas as pd

def convert_txt_to_csv(input_folder, output_folder):
    # Ensure output folder exists
    os.makedirs(output_folder, exist_ok=True)

    for filename in os.listdir(input_folder):
        if filename.lower().endswith('.txt'):
            txt_path = os.path.join(input_folder, filename)
            csv_name = os.path.splitext(filename)[0] + '.csv'
            csv_path = os.path.join(output_folder, csv_name)

            # Read the text file (default encoding)
            with open(txt_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Parse lines into speaker and dialogue
            lines = []
            for line in content.strip().split('\n'):
                if ':' in line:
                    speaker, dialogue = line.split(':', 1)
                    lines.append({
                        'speaker': speaker.strip(),
                        'line': dialogue.strip()
                    })

            # Create DataFrame and save to CSV with UTF-8 BOM
            df = pd.DataFrame(lines)
            df.to_csv(csv_path, index=False, encoding='utf-8-sig')  # <-- BOM for Excel compatibility

            print(f"✅ Converted: {filename} → {csv_name}")

# ✏️ Example usage — Update these paths
input_folder = 'D:/Startups/Wisme/Development/ResearchApp/Python csv script generator/txt Files'
output_folder = 'D:/Startups/Wisme/Development/ResearchApp/Python csv script generator/csv Files'

convert_txt_to_csv(input_folder, output_folder)
