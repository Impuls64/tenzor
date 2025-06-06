# task3.py
import json
import random
import sys
from typing import Dict, List, Tuple

def generate_version_numbers(template: str) -> Tuple[str, str]:
    """Generate two version numbers based on template"""
    parts = template.split('.')
    
    variants = []
    for _ in range(2):
        new_parts = []
        for part in parts:
            if part == '*':
                new_parts.append(str(random.randint(0, 9)))
            else:
                new_parts.append(part)
        variants.append('.'.join(new_parts))
    
    return tuple(variants)

def parse_config(config_file: str) -> Dict[str, str]:
    """Parse JSON config file"""
    with open(config_file, 'r') as f:
        return json.load(f)

def version_to_tuple(version: str) -> Tuple[int, ...]:
    """Convert version string to tuple of integers for comparison"""
    return tuple(map(int, version.split('.')))

def main():
    if len(sys.argv) != 3:
        print("Usage: python task3.py <version> <config_file>")
        sys.exit(1)
    
    input_version = sys.argv[1]
    config_file = sys.argv[2]
    
    try:
        config = parse_config(config_file)
        all_versions = []
        
        print("Generated version numbers:")
        for key, template in config.items():
            v1, v2 = generate_version_numbers(template)
            print(f"{key}: {v1}, {v2}")
            all_versions.extend([v1, v2])
        
        # Sort all versions
        sorted_versions = sorted(all_versions, key=version_to_tuple)
        print("\nSorted versions:")
        for v in sorted_versions:
            print(v)
        
        # Filter versions older than input version
        input_tuple = version_to_tuple(input_version)
        older_versions = [v for v in sorted_versions 
                         if version_to_tuple(v) < input_tuple]
        
        print("\nVersions older than", input_version)
        for v in older_versions:
            print(v)
    
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()