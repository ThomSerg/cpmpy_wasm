import sys
from pathlib import Path
from zipfile import ZipFile

wheel_dir = Path("build")
output_zip = wheel_dir / "all_wheels.zip"

# List of wheels passed via CLI
wheels = sys.argv[1:]

with ZipFile(output_zip, "w") as zipf:
    for wheel_name in wheels:
        wheel_path = wheel_dir / wheel_name
        if not wheel_path.exists():
            print(f"Warning: {wheel_name} not found, skipping.")
            continue
        zipf.write(wheel_path, arcname=wheel_name)

print(f"Created {output_zip} with {len(wheels)} wheel(s).")
