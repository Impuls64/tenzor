#!/usr/bin/env python3
# task2_repo_arg.py - Универсальный сборщик с передачей репозитория в аргументах

import os
import json
import shutil
import subprocess
import argparse
from datetime import datetime
import logging
from typing import List

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

def clone_repo(repo_url: str, temp_dir: str):
    logging.info(f"Клонируем репозиторий {repo_url} во временную директорию {temp_dir}")
    try:
        subprocess.run(["git", "clone", repo_url, temp_dir], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        logging.error(f"Ошибка при клонировании репозитория: {e.stderr.decode().strip()}")
        raise

def clean_directory(root_dir: str, src_path: str):
    logging.info(f"Очищаем директорию {root_dir}, оставляем только {src_path}")
    
    rel_path = os.path.relpath(src_path, root_dir)
    path_parts = rel_path.split(os.sep)
    
    for item in os.listdir(root_dir):
        item_path = os.path.join(root_dir, item)
        if item != path_parts[0] and os.path.isdir(item_path):
            shutil.rmtree(item_path)
            logging.info(f"Удалена директория: {item}")

def find_source_files(src_dir: str) -> List[str]:
    """Находит файлы с нужными расширениями только в указанной директории"""
    extensions = ('.py', '.js', '.sh')
    source_files = []
    
    try:
        for item in os.listdir(src_dir):
            item_path = os.path.join(src_dir, item)
            if os.path.isfile(item_path) and item.lower().endswith(extensions):
                source_files.append(item)
    except Exception as e:
        logging.error(f"Ошибка при поиске файлов: {str(e)}")
        raise
    
    return sorted(source_files)

def create_version_file(src_dir: str, version: str):
    logging.info(f"Создаем version.json в {src_dir}")
    
    files = find_source_files(src_dir)
    logging.info(f"Найдены файлы: {files}")
    
    version_data = {
        "name": "hello world",
        "version": version,
        "files": files
    }
    
    version_path = os.path.join(src_dir, "version.json")
    with open(version_path, 'w') as f:
        json.dump(version_data, f, indent=2)
    
    logging.info(f"Файл version.json создан: {version_path}")

def create_archive(src_dir: str, output_name: str):
    logging.info(f"Создаем архив {output_name}.zip из {src_dir}")
    shutil.make_archive(output_name, 'zip', src_dir)
    logging.info(f"Архив создан: {output_name}.zip")

def build_package(repo_url: str, src_path: str, version: str):
    start_time = datetime.now()
    setup_logging()
    
    try:
        # Создаем временную директорию
        temp_dir = "temp_repo"
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
        
        # 1. Клонируем репозиторий
        clone_repo(repo_url, temp_dir)
        
        # Полный путь к исходникам
        full_src_path = os.path.join(temp_dir, src_path)
        if not os.path.exists(full_src_path):
            raise ValueError(f"Директория с исходниками не найдена: {full_src_path}")
        
        # Имя последней директории для архива
        last_dir = os.path.basename(os.path.normpath(full_src_path))
        
        # 2. Очищаем директорию
        clean_directory(temp_dir, full_src_path)
        
        # 3. Создаем version.json
        create_version_file(full_src_path, version)
        
        # 4. Создаем архив
        current_date = datetime.now().strftime("%Y%m%d")
        archive_name = f"{last_dir}{current_date}"
        create_archive(full_src_path, archive_name)
        
        logging.info(f"Сборка завершена успешно. Архив: {archive_name}.zip")
    except Exception as e:
        logging.error(f"Ошибка при сборке: {str(e)}")
        raise
    finally:
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
        
        end_time = datetime.now()
        logging.info(f"Общее время выполнения: {(end_time - start_time).total_seconds():.2f} секунд")

def main():
    parser = argparse.ArgumentParser(description='Универсальный сборщик пакетов')
    parser.add_argument('repo_url', help='URL git-репозитория')
    parser.add_argument('src_path', help='Относительный путь к исходникам в репозитории')
    parser.add_argument('version', help='Версия пакета')
    
    args = parser.parse_args()
    
    print(f"Сборка пакета из репозитория: {args.repo_url}")
    print(f"Путь к исходникам: {args.src_path}")
    print(f"Версия: {args.version}")
    
    try:
        build_package(args.repo_url, args.src_path, args.version)
    except Exception as e:
        print(f"\nОшибка: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()