![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows Server](https://img.shields.io/badge/Windows_Server-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![MikroTik](https://img.shields.io/badge/MikroTik-000000?style=for-the-badge&logo=mikrotik&logoColor=white)

Привет! Я специалист по ИТ-инфраструктуре с опытом поддержки гетерогенных сетей. Стремлюсь автоматизировать рутину (IaC, скриптинг), чтобы бизнес получал отказоустойчивые и безопасные сервисы. 

В этом репозитории собраны мои наработки по автоматизации системного администрирования, мониторингу оборудования и аудиту безопасности.

---

## 🛠 Ключевые компетенции

* **Инфраструктура & Сети:** Windows Server (AD, GPO), Linux, VLAN, VPN, маршрутизация (MikroTik, Cisco), Firewall (Iptables/nftables).
* **Скриптинг:** PowerShell, Bash, Python (написание утилит, парсеров, автоматизация бэкапов).
* **Мониторинг:** Настройка кастомных алертов, работа с аппаратными датчиками (lm-sensors).
* **Безопасность:** Харденинг серверов, анализ логов, приватность данных. Практикую работу с privacy-focused системами (GrapheneOS, настройка изолированных песочниц Google Play).

---

## 📂 Структура репозитория (Автоматизация)

<details>
  <summary><b>1. Управление Active Directory (AD_Management)</b> <i>[Нажми, чтобы раскрыть]</i></summary>
  
  Инструменты для работы с Windows Server и доменами:
  * `Create-AdUsers.ps1` — Автоматизированное массовое создание пользователей из CSV (генерация логинов, безопасная установка паролей, логирование).
  * `Disable-InactiveUsers.ps1` — Аудит безопасности AD: поиск учеток без активности более 90 дней, автоматическое отключение, удаление из групп и перенос в архивную OU.
</details>

<details>
  <summary><b>2. Сетевая автоматизация (Network_Automation)</b> <i>[Нажми, чтобы раскрыть]</i></summary>
  
  Конфигурация как код (IaC) для сетевого оборудования:
  * `mikrotik_auto_backup.sh` — Bash-скрипт для подключения к MikroTik RouterOS по SSH, создания дампа конфигурации (export) и защищенного скачивания с автоматической ротацией старых архивов.
</details>

<details>
  <summary><b>3. Бэкапы и Алерты (Backup_Alerts)</b> <i>[Нажми, чтобы раскрыть]</i></summary>
  
  Обеспечение сохранности данных:
  * `backup_with_tg_alert.sh` — Инкрементальное резервное копирование веб-проектов с мгновенной отправкой статусных уведомлений (Success/Error) через Telegram Bot API.
</details>

<details>
  <summary><b>4. Аудит безопасности (Security_Audit)</b> <i>[Нажми, чтобы раскрыть]</i></summary>
  
  Утилиты для мониторинга инцидентов:
  * `ssh_brute_analyzer.py` — CLI-инструмент на Python для парсинга `auth.log` (с помощью RegEx), выявления попыток брутфорса SSH и формирования топа атакующих IP-адресов.
</details>

<details>
  <summary><b>5. Аппаратный мониторинг (Hardware_Monitoring)</b> <i>[Нажми, чтобы раскрыть]</i></summary>
  
  Контроль физического состояния оборудования:
  * `cpu_thermal_alert.sh` — Bash-скрипт для предотвращения троттлинга. Отслеживает тепловые пакеты CPU и отправляет алерты при достижении критических температур.
</details>

---

## 🚀 Проекты и инженерный опыт

Мой опыт выходит за рамки классического эникейства и администрирования ОС. Я активно работаю на стыке железа, софта и сетей:

* **Инфраструктура Web & Коммуникаций:** Отвечаю за поддержку серверов (VDS/VPS) проекта `strongagrohim.ru`. Участвую в совместной разработке мобильного приложения для корпоративного мессенджера на базе **Element X** (протокол Matrix).
* **Аппаратный тюнинг (Performance & Overclocking):** Глубоко понимаю архитектуру ПК и серверов. Имею практический опыт тонкой настройки и оптимизации железа (андервольтинг и оверклокинг Xeon E5 1650v3, конфигурация PBO2 Tuner для процессоров архитектуры Ryzen X3D).
* **Стыковые проекты (IoT / 3D / Python):** Нахожу нестандартные решения. Например, в рамках проекта разработки "умной таблетницы" создавал Python-скрипты для автоматизации 3D-моделирования в Blender и работал с Android Manifest для сопутствующего приложения.

---
