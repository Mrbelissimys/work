import re
from collections import Counter
import argparse

def parse_auth_log(log_path, limit):
    """Парсит auth.log и находит неудачные попытки входа SSH"""
    failed_ips = []
    
    # Регулярка для поиска IP адресов в строках "Failed password"
    ip_pattern = re.compile(r"Failed password for .* from ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})")

    try:
        with open(log_path, 'r') as file:
            for line in file:
                if "Failed password" in line and "sshd" in line:
                    match = ip_pattern.search(line)
                    if match:
                        failed_ips.append(match.group(1))
                        
        if not failed_ips:
            print("Неудачных попыток входа не найдено. Отличная работа!")
            return

        # Подсчет частоты IP
        ip_counts = Counter(failed_ips)
        
        print(f"--- ТОП {limit} АТАКУЮЩИХ IP АДРЕСОВ ---")
        for ip, count in ip_counts.most_common(limit):
            print(f"IP: {ip:<15} | Попыток: {count}")
            
    except FileNotFoundError:
        print(f"Ошибка: Файл лога {log_path} не найден.")
    except PermissionError:
        print("Ошибка: Нет прав для чтения файла. Запустите скрипт через sudo.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Анализатор логов SSH")
    parser.add_argument("-f", "--file", default="/var/log/auth.log", help="Путь к файлу лога (по умолчанию /var/log/auth.log)")
    parser.add_argument("-l", "--limit", type=int, default=5, help="Количество IP для вывода (по умолчанию 5)")
    
    args = parser.parse_args()
    parse_auth_log(args.file, args.limit)