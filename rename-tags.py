import os
import shutil
import argparse

def rename_platform_tag(
    src_dir,
    tgt_dir,
    old_platform_tag,
    new_platform_tag
):
    if not os.path.exists(tgt_dir):
        os.makedirs(tgt_dir)
    
    wheel_files = [f for f in os.listdir(src_dir) if f.endswith('.whl')]
    
    for whl in wheel_files:
        if not whl.endswith(old_platform_tag + '.whl'):
            print(f"Skipping wheel not matching old platform tag: {whl}")
            continue
        
        new_name = whl[:-len(old_platform_tag + '.whl')] + new_platform_tag + '.whl'
        
        src_path = os.path.join(src_dir, whl)
        dst_path = os.path.join(tgt_dir, new_name)
        
        shutil.copyfile(src_path, dst_path)
        print(f"Copied {whl} → {new_name}")

def main():
    parser = argparse.ArgumentParser(description="Rename wheel files replacing platform tags.")
    parser.add_argument("--src-dir", default=".", help="Source directory containing wheel files")
    parser.add_argument("--tgt-dir", default=".", help="Target directory to copy renamed wheel files")
    parser.add_argument("--old-platform-tag", default="pyodide_2024_0_wasm32", help="Old platform tag to replace")
    parser.add_argument("--new-platform-tag", default="emscripten_3_1_58_wasm32", help="New platform tag to use")
    
    args = parser.parse_args()
    
    rename_platform_tag(
        src_dir=args.src_dir,
        tgt_dir=args.tgt_dir,
        old_platform_tag=args.old_platform_tag,
        new_platform_tag=args.new_platform_tag,
    )

if __name__ == "__main__":
    main()
