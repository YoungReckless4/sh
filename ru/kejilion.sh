#!/bin/bash
sh_v="4.3.10"


gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_kjlan='\033[96m'


canshu="default"
permission_granted="false"
ENABLE_STATS="true"


quanju_canshu() {
if [ "$canshu" = "CN" ]; then
	zhushi=0
	gh_proxy="https://gh.kejilion.pro/"
elif [ "$canshu" = "V6" ]; then
	zhushi=1
	gh_proxy="https://gh.kejilion.pro/"
else
	zhushi=1  # 0 表示执行，1 表示不执行
	gh_proxy="https://"
fi

gh_https_url="https://"

}
quanju_canshu



# Определите функцию для выполнения команды
run_command() {
	if [ "$zhushi" -eq 0 ]; then
		"$@"
	fi
}


canshu_v6() {
	if grep -q '^canshu="V6"' /usr/local/bin/k > /dev/null 2>&1; then
		sed -i 's/^canshu="default"/canshu="V6"/' ~/kejilion.sh
	fi
}


CheckFirstRun_true() {
	if grep -q '^permission_granted="true"' /usr/local/bin/k > /dev/null 2>&1; then
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/kejilion.sh
	fi
}



# Эта функция собирает скрытую информацию о функциях и записывает текущий номер версии сценария, время использования, версию системы, архитектуру ЦП, страну компьютера и имя функции, используемой пользователем. Он не содержит никакой конфиденциальной информации, так что не волнуйтесь! Пожалуйста, поверьте мне!
# Для чего создана эта функция? Цель состоит в том, чтобы лучше понять функции, которые пользователи любят использовать, а также в дальнейшей оптимизации функций и запуске большего количества функций, отвечающих потребностям пользователей.
# Полный текст можно найти по адресу вызова функции send_stats. Он прозрачен и имеет открытый исходный код. Если у вас есть какие-либо опасения, вы можете отказаться от его использования.



send_stats() {
	if [ "$ENABLE_STATS" == "false" ]; then
		return
	fi

	local country=$(curl -s ipinfo.io/country)
	local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
	local cpu_arch=$(uname -m)

	(
		curl -s -X POST "https://api.kejilion.pro/api/log" \
			-H "Content-Type: application/json" \
			-d "{\"action\":\"$1\",\"timestamp\":\"$(date -u '+%Y-%m-%d %H:%M:%S')\",\"country\":\"$country\",\"os_info\":\"$os_info\",\"cpu_arch\":\"$cpu_arch\",\"version\":\"$sh_v\"}" \
		&>/dev/null
	) &

}


yinsiyuanquan2() {

if grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
	sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/kejilion.sh
fi

}



canshu_v6
CheckFirstRun_true
yinsiyuanquan2


sed -i '/^alias k=/d' ~/.bashrc > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.profile > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.bash_profile > /dev/null 2>&1
cp -f ./kejilion.sh ~/kejilion.sh > /dev/null 2>&1
cp -f ~/kejilion.sh /usr/local/bin/k > /dev/null 2>&1
ln -sf /usr/local/bin/k /usr/bin/k > /dev/null 2>&1



CheckFirstRun_false() {
	if grep -q '^permission_granted="false"' /usr/local/bin/k > /dev/null 2>&1; then
		UserLicenseAgreement
	fi
}

# Предложить пользователю согласиться с условиями
UserLicenseAgreement() {
	clear
	echo -e "${gl_kjlan}Добро пожаловать в набор инструментов для сценариев Technology Lion${gl_bai}"
	echo "При первом использовании скрипта прочтите и согласитесь с Пользовательским лицензионным соглашением."
	echo "Пользовательское лицензионное соглашение: https://blog.kejilion.pro/user-license-agreement/"
	echo -e "----------------------"
	read -e -p "Согласны ли вы с вышеуказанными условиями? (да/нет):" user_input


	if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
		send_stats "Лицензионное соглашение"
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/kejilion.sh
		sed -i 's/^permission_granted="false"/permission_granted="true"/' /usr/local/bin/k
	else
		send_stats "доступ запрещен"
		clear
		exit
	fi
}

CheckFirstRun_false





ip_address() {

get_public_ip() {
	curl -s https://ipinfo.io/ip && echo
}

get_local_ip() {
	ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[^ ]+' || \
	hostname -I 2>/dev/null | awk '{print $1}' || \
	ifconfig 2>/dev/null | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print $2}' | head -n1
}

public_ip=$(get_public_ip)
isp_info=$(curl -s --max-time 3 http://ipinfo.io/org)


if echo "$isp_info" | grep -Eiq 'CHINANET|mobile|unicom|telecom'; then
  ipv4_address=$(get_local_ip)
else
  ipv4_address="$public_ip"
fi


# ipv4_address=$(curl -s https://ipinfo.io/ip && echo)
ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip && echo)

}



install() {
	if [ $# -eq 0 ]; then
		echo "Параметры пакета не указаны!"
		return 1
	fi

	for package in "$@"; do
		if ! command -v "$package" &>/dev/null; then
			echo -e "${gl_kjlan}Установка$package...${gl_bai}"
			if command -v dnf &>/dev/null; then
				dnf -y update
				dnf install -y epel-release
				dnf install -y "$package"
			elif command -v yum &>/dev/null; then
				yum -y update
				yum install -y epel-release
				yum install -y "$package"
			elif command -v apt &>/dev/null; then
				apt update -y
				apt install -y "$package"
			elif command -v apk &>/dev/null; then
				apk update
				apk add "$package"
			elif command -v pacman &>/dev/null; then
				pacman -Syu --noconfirm
				pacman -S --noconfirm "$package"
			elif command -v zypper &>/dev/null; then
				zypper refresh
				zypper install -y "$package"
			elif command -v opkg &>/dev/null; then
				opkg update
				opkg install "$package"
			elif command -v pkg &>/dev/null; then
				pkg update
				pkg install -y "$package"
			else
				echo "Неизвестный менеджер пакетов!"
				return 1
			fi
		fi
	done
}


check_disk_space() {
	local required_gb=$1
	local path=${2:-/}

	mkdir -p "$path"

	local required_space_mb=$((required_gb * 1024))
	local available_space_mb=$(df -m "$path" | awk 'NR==2 {print $4}')

	if [ "$available_space_mb" -lt "$required_space_mb" ]; then
		echo -e "${gl_huang}намекать:${gl_bai}Недостаточно места на диске!"
		echo "Текущее доступное пространство: $((available_space_mb/1024))G"
		echo "Минимально необходимое пространство:${required_gb}G"
		echo "Установка не может быть продолжена. Пожалуйста, очистите место на диске и повторите попытку."
		send_stats "Недостаточно места на диске"
		break_end
		kejilion
	fi
}



install_dependency() {
	switch_mirror false false
	check_port
	check_swap
	prefer_ipv4
	auto_optimize_dns
	install wget unzip tar jq grep

}

remove() {
	if [ $# -eq 0 ]; then
		echo "Параметры пакета не указаны!"
		return 1
	fi

	for package in "$@"; do
		echo -e "${gl_kjlan}Удаление$package...${gl_bai}"
		if command -v dnf &>/dev/null; then
			dnf remove -y "$package"
		elif command -v yum &>/dev/null; then
			yum remove -y "$package"
		elif command -v apt &>/dev/null; then
			apt purge -y "$package"
		elif command -v apk &>/dev/null; then
			apk del "$package"
		elif command -v pacman &>/dev/null; then
			pacman -Rns --noconfirm "$package"
		elif command -v zypper &>/dev/null; then
			zypper remove -y "$package"
		elif command -v opkg &>/dev/null; then
			opkg remove "$package"
		elif command -v pkg &>/dev/null; then
			pkg delete -y "$package"
		else
			echo "Неизвестный менеджер пакетов!"
			return 1
		fi
	done
}


# Универсальная функция systemctl, подходящая для различных дистрибутивов.
systemctl() {
	local COMMAND="$1"
	local SERVICE_NAME="$2"

	if command -v apk &>/dev/null; then
		service "$SERVICE_NAME" "$COMMAND"
	else
		/bin/systemctl "$COMMAND" "$SERVICE_NAME"
	fi
}


# Перезапустить службу
restart() {
	systemctl restart "$1"
	if [ $? -eq 0 ]; then
		echo "$1Служба перезапущена."
	else
		echo "Ошибка: Перезапустить$1Служба не удалась."
	fi
}

# Запустить службу
start() {
	systemctl start "$1"
	if [ $? -eq 0 ]; then
		echo "$1Служба началась."
	else
		echo "Ошибка: начать$1Служба не удалась."
	fi
}

# Остановить службу
stop() {
	systemctl stop "$1"
	if [ $? -eq 0 ]; then
		echo "$1Служба остановлена."
	else
		echo "Ошибка: стоп$1Служба не удалась."
	fi
}

# Проверить статус услуги
status() {
	systemctl status "$1"
	if [ $? -eq 0 ]; then
		echo "$1Отображается статус услуги."
	else
		echo "Ошибка: невозможно отобразить$1Статус услуги."
	fi
}


enable() {
	local SERVICE_NAME="$1"
	if command -v apk &>/dev/null; then
		rc-update add "$SERVICE_NAME" default
	else
	   /bin/systemctl enable "$SERVICE_NAME"
	fi

	echo "$SERVICE_NAMEОн настроен на автоматический запуск при загрузке."
}



break_end() {
	  echo -e "${gl_lv}Операция завершена${gl_bai}"
	  echo "Нажмите любую клавишу, чтобы продолжить..."
	  read -n 1 -s -r -p ""
	  echo ""
	  clear
}

kejilion() {
			cd ~
			kejilion_sh
}




stop_containers_or_kill_process() {
	local port=$1
	local containers=$(docker ps --filter "publish=$port" --format "{{.ID}}" 2>/dev/null)

	if [ -n "$containers" ]; then
		docker stop $containers
	else
		install lsof
		for pid in $(lsof -t -i:$port); do
			kill -9 $pid
		done
	fi
}


check_port() {
	stop_containers_or_kill_process 80
	stop_containers_or_kill_process 443
}


install_add_docker_cn() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
	"https://docker.1ms.run",
	"https://docker.m.ixdev.cn",
	"https://hub.rat.dev",
	"https://dockerproxy.net",
	"https://docker-registry.nmqu.com",
	"https://docker.amingg.com",
	"https://docker.hlmirror.com",
	"https://hub1.nat.tf",
	"https://hub2.nat.tf",
	"https://hub3.nat.tf",
	"https://docker.m.daocloud.io",
	"https://docker.kejilion.pro",
	"https://docker.367231.xyz",
	"https://hub.1panel.dev",
	"https://dockerproxy.cool",
	"https://docker.apiba.cn",
	"https://proxy.vvvv.ee"
  ]
}
EOF
fi


enable docker
start docker
restart docker

}



linuxmirrors_install_docker() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source mirrors.huaweicloud.com/docker-ce \
	  --source-registry docker.1ms.run \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
else
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source download.docker.com \
	  --source-registry registry.hub.docker.com \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
fi

install_add_docker_cn

}



install_add_docker() {
	echo -e "${gl_kjlan}Установка среды докера...${gl_bai}"
	if command -v apt &>/dev/null || command -v yum &>/dev/null || command -v dnf &>/dev/null; then
		linuxmirrors_install_docker
	else
		install docker docker-compose
		install_add_docker_cn

	fi
	sleep 2
}


install_docker() {
	if ! command -v docker &>/dev/null; then
		install_add_docker
	fi
}


docker_ps() {
while true; do
	clear
	send_stats "Управление контейнерами Docker"
	echo "Список контейнеров Docker"
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
	echo ""
	echo "Контейнерные операции"
	echo "------------------------"
	echo "1. Создайте новый контейнер"
	echo "------------------------"
	echo "2. Запустить указанный контейнер 6. Запустить все контейнеры"
	echo "3. Остановить указанный контейнер 7. Остановить все контейнеры"
	echo "4. Удалить указанный контейнер 8. Удалить все контейнеры"
	echo "5. Перезапустить указанный контейнер. 9. Перезапустить все контейнеры."
	echo "------------------------"
	echo "11. Войдите в указанный контейнер. 12. Просмотрите журнал контейнера."
	echo "13. Проверка контейнерной сети 14. Проверка занятости контейнера"
	echo "------------------------"
	echo "15. Включите доступ к порту контейнера. 16. Закройте доступ к порту контейнера."
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
	case $sub_choice in
		1)
			send_stats "Создать новый контейнер"
			read -e -p "Введите команду создания:" dockername
			$dockername
			;;
		2)
			send_stats "Запустить указанный контейнер"
			read -e -p "Введите имя контейнера (разделяйте несколько имен контейнеров пробелами):" dockername
			docker start $dockername
			;;
		3)
			send_stats "Остановить указанный контейнер"
			read -e -p "Введите имя контейнера (разделяйте несколько имен контейнеров пробелами):" dockername
			docker stop $dockername
			;;
		4)
			send_stats "Удалить указанный контейнер"
			read -e -p "Введите имя контейнера (разделяйте несколько имен контейнеров пробелами):" dockername
			docker rm -f $dockername
			;;
		5)
			send_stats "Перезапустить указанный контейнер"
			read -e -p "Введите имя контейнера (разделяйте несколько имен контейнеров пробелами):" dockername
			docker restart $dockername
			;;
		6)
			send_stats "Запустить все контейнеры"
			docker start $(docker ps -a -q)
			;;
		7)
			send_stats "Остановить все контейнеры"
			docker stop $(docker ps -q)
			;;
		8)
			send_stats "Удалить все контейнеры"
			read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有容器吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rm -f $(docker ps -a -q)
				;;
			  [Nn])
				;;
			  *)
				echo "Неверный выбор, введите Y или N."
				;;
			esac
			;;
		9)
			send_stats "Перезапустите все контейнеры"
			docker restart $(docker ps -q)
			;;
		11)
			send_stats "Войдите в контейнер"
			read -e -p "Пожалуйста, введите имя контейнера:" dockername
			docker exec -it $dockername /bin/sh
			break_end
			;;
		12)
			send_stats "Просмотр журналов контейнера"
			read -e -p "Пожалуйста, введите имя контейнера:" dockername
			docker logs $dockername
			break_end
			;;
		13)
			send_stats "Посмотреть контейнерную сеть"
			echo ""
			container_ids=$(docker ps -q)
			echo "------------------------------------------------------------"
			printf "%-25s %-25s %-25s\n" "Имя контейнера" "имя сети" "IP-адрес"
			for container_id in $container_ids; do
				local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")
				local container_name=$(echo "$container_info" | awk '{print $1}')
				local network_info=$(echo "$container_info" | cut -d' ' -f2-)
				while IFS= read -r line; do
					local network_name=$(echo "$line" | awk '{print $1}')
					local ip_address=$(echo "$line" | awk '{print $2}')
					printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
				done <<< "$network_info"
			done
			break_end
			;;
		14)
			send_stats "Посмотреть заполняемость контейнера"
			docker stats --no-stream
			break_end
			;;

		15)
			send_stats "Разрешить доступ к порту контейнера"
			read -e -p "Пожалуйста, введите имя контейнера:" docker_name
			ip_address
			clear_container_rules "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		16)
			send_stats "Заблокировать доступ к порту контейнера"
			read -e -p "Пожалуйста, введите имя контейнера:" docker_name
			ip_address
			block_container_port "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done
}


docker_image() {
while true; do
	clear
	send_stats "Управление образами Docker"
	echo "Список образов Docker"
	docker image ls
	echo ""
	echo "Операция зеркала"
	echo "------------------------"
	echo "1. Получить указанное изображение 3. Удалить указанное изображение"
	echo "2. Обновить указанное изображение. 4. Удалить все изображения."
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
	case $sub_choice in
		1)
			send_stats "Вытащить изображение"
			read -e -p "Введите название изображения (разделяйте несколько названий изображений пробелами):" imagenames
			for name in $imagenames; do
				echo -e "${gl_kjlan}Получение изображения:$name${gl_bai}"
				docker pull $name
			done
			;;
		2)
			send_stats "Обновить изображение"
			read -e -p "Введите название изображения (разделяйте несколько названий изображений пробелами):" imagenames
			for name in $imagenames; do
				echo -e "${gl_kjlan}Обновление изображения:$name${gl_bai}"
				docker pull $name
			done
			;;
		3)
			send_stats "Удалить изображение"
			read -e -p "Введите название изображения (разделяйте несколько названий изображений пробелами):" imagenames
			for name in $imagenames; do
				docker rmi -f $name
			done
			;;
		4)
			send_stats "Удалить все изображения"
			read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有镜像吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rmi -f $(docker images -q)
				;;
			  [Nn])
				;;
			  *)
				echo "Неверный выбор, введите Y или N."
				;;
			esac
			;;
		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done


}





check_crontab_installed() {
	if ! command -v crontab >/dev/null 2>&1; then
		install_crontab
	fi
}



install_crontab() {

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case "$ID" in
			ubuntu|debian|kali)
				apt update
				apt install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			centos|rhel|almalinux|rocky|fedora)
				yum install -y cronie
				systemctl enable crond
				systemctl start crond
				;;
			alpine)
				apk add --no-cache cronie
				rc-update add crond
				rc-service crond start
				;;
			arch|manjaro)
				pacman -S --noconfirm cronie
				systemctl enable cronie
				systemctl start cronie
				;;
			opensuse|suse|opensuse-tumbleweed)
				zypper install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			iStoreOS|openwrt|ImmortalWrt|lede)
				opkg update
				opkg install cron
				/etc/init.d/cron enable
				/etc/init.d/cron start
				;;
			FreeBSD)
				pkg install -y cronie
				sysrc cron_enable="YES"
				service cron start
				;;
			*)
				echo "Неподдерживаемые дистрибутивы:$ID"
				return
				;;
		esac
	else
		echo "Невозможно определить операционную систему."
		return
	fi

	echo -e "${gl_lv}crontab установлен и служба cron запущена.${gl_bai}"
}



docker_ipv6_on() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"
	local REQUIRED_IPV6_CONFIG='{"ipv6": true, "fixed-cidr-v6": "2001:db8:1::/64"}'

	# Проверьте, существует ли файл конфигурации, если нет, создайте файл и пропишите настройки по умолчанию.
	if [ ! -f "$CONFIG_FILE" ]; then
		echo "$REQUIRED_IPV6_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
	else
		# Используйте jq для обработки обновлений файла конфигурации.
		local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

		# Проверьте, есть ли в текущей конфигурации настройки ipv6.
		local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq '.ipv6 // false')

		# Обновите конфигурацию и включите IPv6.
		if [[ "$CURRENT_IPV6" == "false" ]]; then
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {ipv6: true, "fixed-cidr-v6": "2001:db8:1::/64"}')
		else
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {"fixed-cidr-v6": "2001:db8:1::/64"}')
		fi

		# Сравните исходную конфигурацию с новой конфигурацией
		if [[ "$ORIGINAL_CONFIG" == "$UPDATED_CONFIG" ]]; then
			echo -e "${gl_huang}Доступ по IPv6 в настоящее время включен${gl_bai}"
		else
			echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
			restart docker
		fi
	fi
}


docker_ipv6_off() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"

	# Проверьте, существует ли файл конфигурации
	if [ ! -f "$CONFIG_FILE" ]; then
		echo -e "${gl_hong}Конфигурационный файл не существует${gl_bai}"
		return
	fi

	# Чтение текущей конфигурации
	local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

	# Используйте jq для обработки обновлений файла конфигурации.
	local UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq 'del(.["fixed-cidr-v6"]) | .ipv6 = false')

	# Проверьте текущий статус ipv6
	local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq -r '.ipv6 // false')

	# Сравните исходную конфигурацию с новой конфигурацией
	if [[ "$CURRENT_IPV6" == "false" ]]; then
		echo -e "${gl_huang}Доступ по IPv6 на данный момент закрыт${gl_bai}"
	else
		echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
		echo -e "${gl_huang}Доступ по IPv6 успешно закрыт${gl_bai}"
	fi
}



save_iptables_rules() {
	mkdir -p /etc/iptables
	touch /etc/iptables/rules.v4
	iptables-save > /etc/iptables/rules.v4
	check_crontab_installed
	crontab -l | grep -v 'iptables-restore' | crontab - > /dev/null 2>&1
	(crontab -l ; echo '@reboot iptables-restore < /etc/iptables/rules.v4') | crontab - > /dev/null 2>&1

}




iptables_open() {
	install iptables
	save_iptables_rules
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -F

	ip6tables -P INPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -F

}



open_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "Укажите хотя бы один номер порта"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# Удалить существующие правила выключения
		iptables -D INPUT -p tcp --dport $port -j DROP 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j DROP 2>/dev/null

		# Добавить открытое правило
		if ! iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j ACCEPT
		fi

		if ! iptables -C INPUT -p udp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j ACCEPT
			echo "Порт открыт$port"
		fi
	done

	save_iptables_rules
	send_stats "Порт открыт"
}


close_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "Укажите хотя бы один номер порта"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# Удалить существующие открытые правила
		iptables -D INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j ACCEPT 2>/dev/null

		# Добавить правило отключения
		if ! iptables -C INPUT -p tcp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j DROP
		fi

		if ! iptables -C INPUT -p udp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j DROP
			echo "Порт закрыт$port"
		fi
	done

	# Удалить существующие правила (если есть)
	iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i lo -j ACCEPT 2>/dev/null

	# Вставьте новое правило в первое
	iptables -I INPUT 1 -i lo -j ACCEPT
	iptables -I FORWARD 1 -i lo -j ACCEPT

	save_iptables_rules
	send_stats "Порт закрыт"
}


allow_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "Укажите хотя бы один IP-адрес или IP-сегмент."
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# Удалить существующие правила блокировки
		iptables -D INPUT -s $ip -j DROP 2>/dev/null

		# Добавить разрешающее правило
		if ! iptables -C INPUT -s $ip -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j ACCEPT
			echo "Выпущенный IP$ip"
		fi
	done

	save_iptables_rules
	send_stats "Выпущенный IP"
}

block_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "Укажите хотя бы один IP-адрес или IP-сегмент."
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# Удалить существующие разрешающие правила
		iptables -D INPUT -s $ip -j ACCEPT 2>/dev/null

		# Добавить правило блокировки
		if ! iptables -C INPUT -s $ip -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j DROP
			echo "IP заблокирован$ip"
		fi
	done

	save_iptables_rules
	send_stats "IP заблокирован"
}







enable_ddos_defense() {
	# Включите защиту от DDoS
	iptables -A DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A DOCKER-USER -p tcp --syn -j DROP
	iptables -A DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A DOCKER-USER -p udp -j DROP
	iptables -A INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A INPUT -p tcp --syn -j DROP
	iptables -A INPUT -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A INPUT -p udp -j DROP

	send_stats "Включите защиту от DDoS"
}

# Отключить защиту от DDoS
disable_ddos_defense() {
	# Отключить защиту от DDoS
	iptables -D DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p tcp --syn -j DROP 2>/dev/null
	iptables -D DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p udp -j DROP 2>/dev/null
	iptables -D INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D INPUT -p tcp --syn -j DROP 2>/dev/null
	iptables -D INPUT -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D INPUT -p udp -j DROP 2>/dev/null

	send_stats "Отключить защиту от DDoS"
}





# Функции управления национальными правилами ИС
manage_country_rules() {
	local action="$1"
	shift  # 去掉第一个参数，剩下的全是国家代码

	install ipset

	for country_code in "$@"; do
		local ipset_name="${country_code,,}_block"
		local download_url="http://www.ipdeny.com/ipblocks/data/countries/${country_code,,}.zone"

		case "$action" in
			block)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "Ошибка: скачать$country_codeОшибка файла IP-зоны"
					continue
				fi

				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"

				iptables -I INPUT -m set --match-set "$ipset_name" src -j DROP

				echo "Заблокировано успешно$country_codeIP-адрес"
				rm "${country_code,,}.zone"
				;;

			allow)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "Ошибка: скачать$country_codeОшибка файла IP-зоны"
					continue
				fi

				ipset flush "$ipset_name"
				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"


				iptables -P INPUT DROP
				iptables -A INPUT -m set --match-set "$ipset_name" src -j ACCEPT

				echo "Успешно разрешено$country_codeIP-адрес"
				rm "${country_code,,}.zone"
				;;

			unblock)
				iptables -D INPUT -m set --match-set "$ipset_name" src -j DROP 2>/dev/null

				if ipset list "$ipset_name" &> /dev/null; then
					ipset destroy "$ipset_name"
				fi

				echo "Удален успешно$country_codeОграничения по IP-адресу"
				;;

			*)
				echo "Использование: Manage_country_rules {block|allow|unblock} <код_страны...>"
				;;
		esac
	done
}










iptables_panel() {
  root_use
  install iptables
  save_iptables_rules
  while true; do
		  clear
		  echo "Расширенное управление брандмауэром"
		  send_stats "Расширенное управление брандмауэром"
		  echo "------------------------"
		  iptables -L INPUT
		  echo ""
		  echo "Управление брандмауэром"
		  echo "------------------------"
		  echo "1. Откройте назначенный порт 2. Закройте назначенный порт"
		  echo "3. Откройте все порты 4. Закройте все порты"
		  echo "------------------------"
		  echo "5. Белый список IP-адресов 6. Черный список IP-адресов"
		  echo "7. Очистить указанный IP"
		  echo "------------------------"
		  echo "11. Разрешить PING 12. Отключить PING"
		  echo "------------------------"
		  echo "13. Запустить защиту от DDOS 14. Выключить защиту от DDOS"
		  echo "------------------------"
		  echo "15. Блокировать IP-адреса указанной страны. 16. Разрешить только IP-адреса указанной страны."
		  echo "17. Снять ограничения по IP в определенных странах."
		  echo "------------------------"
		  echo "0. Вернуться в предыдущее меню"
		  echo "------------------------"
		  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
		  case $sub_choice in
			  1)
				  read -e -p "Пожалуйста, введите номер открытого порта:" o_port
				  open_port $o_port
				  send_stats "Открыть указанный порт"
				  ;;
			  2)
				  read -e -p "Пожалуйста, введите номер закрытого порта:" c_port
				  close_port $c_port
				  send_stats "Закрыть указанный порт"
				  ;;
			  3)
				  # Открыть все порты
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT ACCEPT
				  iptables -P FORWARD ACCEPT
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "Открыть все порты"
				  ;;
			  4)
				  # Закройте все порты
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT DROP
				  iptables -P FORWARD DROP
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "Закройте все порты"
				  ;;

			  5)
				  # Белый список IP-адресов
				  read -e -p "Пожалуйста, введите разрешенный IP-адрес или сегмент IP:" o_ip
				  allow_ip $o_ip
				  ;;
			  6)
				  # Черный список IP-адресов
				  read -e -p "Пожалуйста, введите заблокированный IP-адрес или диапазон IP-адресов:" c_ip
				  block_ip $c_ip
				  ;;
			  7)
				  # Очистить указанный IP
				  read -e -p "Пожалуйста, введите очищенный IP:" d_ip
				  iptables -D INPUT -s $d_ip -j ACCEPT 2>/dev/null
				  iptables -D INPUT -s $d_ip -j DROP 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "Очистить указанный IP"
				  ;;
			  11)
				  # Разрешить PING
				  iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
				  iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "Разрешить PING"
				  ;;
			  12)
				  # Отключить ПИНГ
				  iptables -D INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null
				  iptables -D OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "Отключить ПИНГ"
				  ;;
			  13)
				  enable_ddos_defense
				  ;;
			  14)
				  disable_ddos_defense
				  ;;

			  15)
				  read -e -p "Введите заблокированный код страны (несколько кодов стран могут быть разделены пробелами, например CN US JP):" country_code
				  manage_country_rules block $country_code
				  send_stats "разрешить странам$country_codeИП"
				  ;;
			  16)
				  read -e -p "Введите разрешенные коды стран (несколько кодов стран могут быть разделены пробелами, например CN US JP):" country_code
				  manage_country_rules allow $country_code
				  send_stats "блокировать страну$country_codeИП"
				  ;;

			  17)
				  read -e -p "Введите очищенный код страны (несколько кодов стран могут быть разделены пробелами, например CN US JP):" country_code
				  manage_country_rules unblock $country_code
				  send_stats "чистая страна$country_codeИП"
				  ;;

			  *)
				  break  # 跳出循环，退出菜单
				  ;;
		  esac
  done

}






add_swap() {
	local new_swap=$1  # 获取传入的参数

	# Получить все разделы подкачки в текущей системе.
	local swap_partitions=$(grep -E '^/dev/' /proc/swaps | awk '{print $1}')

	# Обход и удаление всех разделов подкачки
	for partition in $swap_partitions; do
		swapoff "$partition"
		wipefs -a "$partition"
		mkswap -f "$partition"
	done

	# Убедитесь, что /swapfile больше не используется.
	swapoff /swapfile

	# Удалить старый файл/файл подкачки
	rm -f /swapfile

	# Создайте новый раздел подкачки
	fallocate -l ${new_swap}M /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile

	sed -i '/\/swapfile/d' /etc/fstab
	echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

	if [ -f /etc/alpine-release ]; then
		echo "nohup swapon /swapfile" > /etc/local.d/swap.start
		chmod +x /etc/local.d/swap.start
		rc-update add local
	fi

	echo -e "Размер виртуальной памяти был скорректирован${gl_huang}${new_swap}${gl_bai}M"
}




check_swap() {

local swap_total=$(free -m | awk 'NR==3{print $2}')

# Определите, нужно ли создавать виртуальную память
[ "$swap_total" -gt 0 ] || add_swap 1024


}









ldnmp_v() {

	  # Получить версию nginx
	  local nginx_version=$(docker exec nginx nginx -v 2>&1)
	  local nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
	  echo -n -e "nginx : ${gl_huang}v$nginx_version${gl_bai}"

	  # Получить версию MySQL
	  local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  local mysql_version=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
	  echo -n -e "            mysql : ${gl_huang}v$mysql_version${gl_bai}"

	  # Получить PHP-версию
	  local php_version=$(docker exec php php -v 2>/dev/null | grep -oP "PHP \K[0-9]+\.[0-9]+\.[0-9]+")
	  echo -n -e "            php : ${gl_huang}v$php_version${gl_bai}"

	  # Получить версию Redis
	  local redis_version=$(docker exec redis redis-server -v 2>&1 | grep -oP "v=+\K[0-9]+\.[0-9]+")
	  echo -e "            redis : ${gl_huang}v$redis_version${gl_bai}"

	  echo "------------------------"
	  echo ""

}



install_ldnmp_conf() {

  # Создайте необходимые каталоги и файлы
  cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/stream.d web/redis web/log/nginx web/letsencrypt && touch web/docker-compose.yml
  wget -O /home/web/nginx.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf
  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/default10.conf

  default_server_ssl

  # Загрузите файл docker-compose.yml и замените его.
  wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/LNMP-docker-compose-10.yml
  dbrootpasswd=$(openssl rand -base64 16) ; dbuse=$(openssl rand -hex 4) ; dbusepasswd=$(openssl rand -base64 8)

  # Замените в файле docker-compose.yml.
  sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
  sed -i "s#kejilionYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
  sed -i "s#kejilion#$dbuse#g" /home/web/docker-compose.yml

}


update_docker_compose_with_db_creds() {

  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml

  if ! grep -q "letsencrypt" /home/web/docker-compose.yml; then
	wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/LNMP-docker-compose-10.yml

  	dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')

	sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
	sed -i "s#kejilionYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
	sed -i "s#kejilion#$dbuse#g" /home/web/docker-compose.yml
  fi

  if grep -q "kjlion/nginx:alpine" /home/web/docker-compose1.yml; then
  	sed -i 's|kjlion/nginx:alpine|nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
	sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
  fi

}





auto_optimize_dns() {
	# Получите код страны (например, CN, США и т. д.)
	local country=$(curl -s ipinfo.io/country)

	# Установите DNS в зависимости от страны
	if [ "$country" = "CN" ]; then
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
	else
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
	fi

	set_dns


}


prefer_ipv4() {
grep -q '^precedence ::ffff:0:0/96  100' /etc/gai.conf 2>/dev/null \
	|| echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
echo "Переключен на приоритет IPv4."
send_stats "Переключен на приоритет IPv4."
}




install_ldnmp() {

	  update_docker_compose_with_db_creds

	  cd /home/web && docker compose up -d
	  sleep 1
  	  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  	  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -

	  fix_phpfpm_conf php
	  fix_phpfpm_conf php74

	  # настройка MySQL
	  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config-1.cnf
	  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
	  rm -rf /home/custom_mysql_config.cnf



	  restart_ldnmp
	  sleep 2

	  clear
	  echo "Среда LDNMP установлена."
	  echo "------------------------"
	  ldnmp_v

}


install_certbot() {

	cd ~
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/auto_cert_renewal.sh
	chmod +x auto_cert_renewal.sh

	check_crontab_installed
	local cron_job="0 0 * * * ~/auto_cert_renewal.sh"
	crontab -l 2>/dev/null | grep -vF "$cron_job" | crontab -
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "Задача продления обновлена"
}


install_ssltls() {
	  docker stop nginx > /dev/null 2>&1
	  cd ~

	  local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	  if [ ! -f "$file_path" ]; then
		 	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
			local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'
			if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
				mkdir -p /etc/letsencrypt/live/$yuming/
				if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
					openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				else
					openssl genpkey -algorithm Ed25519 -out /etc/letsencrypt/live/$yuming/privkey.pem
					openssl req -x509 -key /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				fi
			else
				docker run --rm -p 80:80 -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot certonly --standalone -d "$yuming" --email your@email.com --agree-tos --no-eff-email --force-renewal --key-type ecdsa
			fi
	  fi
	  mkdir -p /home/web/certs/
	  cp /etc/letsencrypt/live/$yuming/fullchain.pem /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1
	  cp /etc/letsencrypt/live/$yuming/privkey.pem /home/web/certs/${yuming}_key.pem > /dev/null 2>&1

	  docker start nginx > /dev/null 2>&1
}



install_ssltls_text() {
	echo -e "${gl_huang}$yumingИнформация об открытом ключе${gl_bai}"
	cat /etc/letsencrypt/live/$yuming/fullchain.pem
	echo ""
	echo -e "${gl_huang}$yumingИнформация о закрытом ключе${gl_bai}"
	cat /etc/letsencrypt/live/$yuming/privkey.pem
	echo ""
	echo -e "${gl_huang}Путь хранения сертификата${gl_bai}"
	echo "Открытый ключ: /etc/letsencrypt/live/$yuming/fullchain.pem"
	echo "Закрытый ключ: /etc/letsencrypt/live/$yuming/privkey.pem"
	echo ""
}





add_ssl() {
echo -e "${gl_huang}Быстро подайте заявку на получение SSL-сертификата и автоматически продлите его до истечения срока действия.${gl_bai}"
yuming="${1:-}"
if [ -z "$yuming" ]; then
	add_yuming
fi
install_docker
install_certbot
docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
install_ssltls
certs_status
install_ssltls_text
ssl_ps
}


ssl_ps() {
	echo -e "${gl_huang}Статус срока действия применяемых сертификатов${gl_bai}"
	echo "Информация о сайте Срок действия сертификата"
	echo "------------------------"
	for cert_dir in /etc/letsencrypt/live/*; do
	  local cert_file="$cert_dir/fullchain.pem"
	  if [ -f "$cert_file" ]; then
		local domain=$(basename "$cert_dir")
		local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
		local formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
		printf "%-30s%s\n" "$domain" "$formatted_date"
	  fi
	done
	echo ""
}




default_server_ssl() {
install openssl

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
else
	openssl genpkey -algorithm Ed25519 -out /home/web/certs/default_server.key
	openssl req -x509 -key /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
fi

openssl rand -out /home/web/certs/ticket12.key 48
openssl rand -out /home/web/certs/ticket13.key 80

}


certs_status() {

	sleep 1

	local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	if [ -f "$file_path" ]; then
		send_stats "Заявка на сертификат доменного имени прошла успешно"
	else
		send_stats "Заявка на сертификат доменного имени не удалась"
		echo -e "${gl_hong}Уведомление:${gl_bai}Не удалось применить сертификат. Проверьте следующие возможные причины и повторите попытку:"
		echo -e "1. Доменное имя написано неправильно ➠ Проверьте, правильно ли введено доменное имя."
		echo -e "2. Проблема с разрешением DNS ➠ Убедитесь, что имя домена правильно преобразовано в IP-адрес сервера."
		echo -e "3. Проблемы с настройкой сети ➠ Если вы используете виртуальные сети, такие как Cloudflare Warp, временно выключите их."
		echo -e "4. Ограничения брандмауэра ➠ Проверьте, открыт ли порт 80/443, и убедитесь, что он доступен."
		echo -e "5. Количество заявок превышает лимит ➠ Let’s Encrypt имеет недельный лимит (5 раз/доменное имя/неделю)."
		echo -e "6. Ограничения на регистрацию внутри страны ➠ Для материкового Китая подтвердите, зарегистрировано ли доменное имя."
		echo "------------------------"
		echo "1. Повторно подать заявку 2. Импортировать существующий сертификат 0. Выйти"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
		case $sub_choice in
	  	  1)
	  	  	send_stats "Повторно подать заявку"
		  	echo "Пожалуйста, попробуйте развернуть еще раз$webname"
		  	add_yuming
		  	install_ssltls
		  	certs_status

	  		  ;;
	  	  2)
	  	  	send_stats "Импортировать существующий сертификат"

			# Определить путь к файлу
			local cert_file="/home/web/certs/${yuming}_cert.pem"
			local key_file="/home/web/certs/${yuming}_key.pem"

			mkdir -p /home/web/certs

			# 1. Введите сертификат (сертификаты ECC и RSA начинаются с BEGIN CERTIFICATE).
			echo "Вставьте содержимое сертификата (CRT/PEM) (дважды нажмите Enter, чтобы завершить):"
			local cert_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$cert_content" == *"-----BEGIN"* ]] && break
				cert_content+="${line}"$'\n'
			done

			# 2. Введите закрытый ключ (совместим с RSA, ECC, PKCS#8).
			echo "Вставьте содержимое закрытого ключа сертификата (закрытый ключ) (дважды нажмите Enter, чтобы завершить):"
			local key_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$key_content" == *"-----BEGIN"* ]] && break
				key_content+="${line}"$'\n'
			done

			# 3. Интеллектуальная проверка
			# Просто укажите «НАЧАТЬ СЕРТИФИКАТ» и «ЧАСТНЫЙ КЛЮЧ», чтобы пройти
			if [[ "$cert_content" == *"-----BEGIN CERTIFICATE-----"* && "$key_content" == *"PRIVATE KEY-----"* ]]; then
				echo -n "$cert_content" > "$cert_file"
				echo -n "$key_content" > "$key_file"

				chmod 644 "$cert_file"
				chmod 600 "$key_file"

				# Определите текущий тип сертификата и отобразите его.
				if [[ "$key_content" == *"EC PRIVATE KEY"* ]]; then
					echo "Обнаружено, что сертификат ECC успешно сохранен."
				else
					echo "Обнаружено, что сертификат RSA успешно сохранен."
				fi
				auth_method="ssl_imported"
			else
				echo "Ошибка: неверный сертификат или формат закрытого ключа!"
				certs_status
			fi
	  		  ;;
	  	  *)
		  	  exit
	  		  ;;
		esac
	fi

}


repeat_add_yuming() {
if [ -e /home/web/conf.d/$yuming.conf ]; then
  send_stats "Повторное использование доменного имени"
  web_del "${yuming}" > /dev/null 2>&1
fi

}


add_yuming() {
	  ip_address
	  echo -e "Сначала разрешите имя домена в локальный IP-адрес:${gl_huang}$ipv4_address  $ipv6_address${gl_bai}"
	  read -e -p "Пожалуйста, введите свой IP-адрес или разрешенное доменное имя:" yuming
}


check_ip_and_get_access_port() {
	local yuming="$1"

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		read -e -p "Введите порт доступа/прослушивания и нажмите Enter, чтобы использовать 80 по умолчанию:" access_port
		access_port=${access_port:-80}
	fi
}



update_nginx_listen_port() {
	local yuming="$1"
	local access_port="$2"
	local conf="/home/web/conf.d/${yuming}.conf"

	# Пропустить, если access_port пуст.
	[ -z "$access_port" ] && return 0

	# Удалить все строки прослушивания
	sed -i '/^[[:space:]]*listen[[:space:]]\+/d' "$conf"

	# Вставьте новое прослушивание после server {
	sed -i "/server {/a\\
	listen ${access_port};\\
	listen [::]:${access_port};
" "$conf"
}



add_db() {
	  dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
	  dbname="${dbname}"

	  dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  docker exec mysql mysql -u root -p"$dbrootpasswd" -e "CREATE DATABASE $dbname; GRANT ALL PRIVILEGES ON $dbname.* TO \"$dbuse\"@\"%\";"
}


restart_ldnmp() {
	  docker exec nginx chown -R nginx:nginx /var/www/html > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec php chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  docker exec php74 chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  cd /home/web && docker compose restart


}

nginx_upgrade() {

  local ldnmp_pods="nginx"
  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="kjlion/${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker images --filter=reference="${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker compose up -d --force-recreate $ldnmp_pods
  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -
  docker exec nginx chown -R nginx:nginx /var/www/html
  docker exec nginx mkdir -p /var/cache/nginx/proxy
  docker exec nginx mkdir -p /var/cache/nginx/fastcgi
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi
  docker restart $ldnmp_pods > /dev/null 2>&1

  send_stats "возобновлять$ldnmp_pods"
  echo "возобновлять${ldnmp_pods}Заканчивать"

}

phpmyadmin_upgrade() {
  local ldnmp_pods="phpmyadmin"
  local local docker_port=8877
  local dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
  local dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')

  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/docker/refs/heads/main/docker-compose.phpmyadmin.yml
  docker compose -f docker-compose.phpmyadmin.yml up -d
  clear
  ip_address

  check_docker_app_ip
  echo "Информация для входа:"
  echo "имя пользователя:$dbuse"
  echo "пароль:$dbusepasswd"
  echo
  send_stats "запускать$ldnmp_pods"
}


cf_purge_cache() {
  local CONFIG_FILE="/home/web/config/cf-purge-cache.txt"
  local API_TOKEN
  local EMAIL
  local ZONE_IDS

  # Проверьте, существует ли файл конфигурации
  if [ -f "$CONFIG_FILE" ]; then
	# Прочтите API_TOKEN и Zone_id из файла конфигурации.
	read API_TOKEN EMAIL ZONE_IDS < "$CONFIG_FILE"
	# Преобразовать ZONE_IDS в массив
	ZONE_IDS=($ZONE_IDS)
  else
	# Подскажите пользователю, следует ли очистить кеш
	read -e -p "Хотите очистить кеш Cloudflare? (да/нет):" answer
	if [[ "$answer" == "y" ]]; then
	  echo "Информация о CF хранится в$CONFIG_FILE, вы можете изменить информацию CF позже"
	  read -e -p "Пожалуйста, введите свой API_TOKEN:" API_TOKEN
	  read -e -p "Пожалуйста, введите свое имя пользователя CF:" EMAIL
	  read -e -p "Пожалуйста, введите Zone_id (разделяйте кратное число пробелами):" -a ZONE_IDS

	  mkdir -p /home/web/config/
	  echo "$API_TOKEN $EMAIL ${ZONE_IDS[*]}" > "$CONFIG_FILE"
	fi
  fi

  # Пройдитесь по каждому идентификатору зоны и выполните команду очистки кэша.
  for ZONE_ID in "${ZONE_IDS[@]}"; do
	echo "Очистка кеша для Zone_id:$ZONE_ID"
	curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: $API_TOKEN" \
	-H "Content-Type: application/json" \
	--data '{"purge_everything":true}'
  done

  echo "Запрос на очистку кэша отправлен."
}



web_cache() {
  send_stats "Очистить кеш сайта"
  cf_purge_cache
  cd /home/web && docker compose restart
}



web_del() {

	send_stats "Удалить данные сайта"
	yuming_list="${1:-}"
	if [ -z "$yuming_list" ]; then
		read -e -p "Чтобы удалить данные сайта, введите свое доменное имя (разделяйте несколько доменных имен пробелами):" yuming_list
		if [[ -z "$yuming_list" ]]; then
			return
		fi
	fi

	for yuming in $yuming_list; do
		echo "Доменное имя удаляется:$yuming"
		rm -r /home/web/html/$yuming > /dev/null 2>&1
		rm /home/web/conf.d/$yuming.conf > /dev/null 2>&1
		rm /home/web/certs/${yuming}_key.pem > /dev/null 2>&1
		rm /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1

		# Преобразование доменного имени в имя базы данных
		dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
		dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')

		# Проверьте, существует ли база данных, прежде чем удалять ее, чтобы избежать ошибок.
		echo "Удаление базы данных:$dbname"
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE ${dbname};" > /dev/null 2>&1
	done

	docker exec nginx nginx -s reload

}


nginx_waf() {
	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	# Определите, следует ли включать или выключать WAF в соответствии с параметром режима.
	if [ "$mode" == "on" ]; then
		# Включите WAF: удалите комментарии
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity on;|\1modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		# Отключите WAF: добавьте комментарий
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity on;|\1# modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "Неверный аргумент: используйте «вкл» или «выкл»."
		return 1
	fi

	# Проверьте образ nginx и обработайте его соответствующим образом.
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi

}

check_waf_status() {
	if grep -q "^\s*#\s*modsecurity on;" /home/web/nginx.conf; then
		waf_status=""
	elif grep -q "modsecurity on;" /home/web/nginx.conf; then
		waf_status="WAF включен."
	else
		waf_status=""
	fi
}


check_cf_mode() {
	if [ -f "/etc/fail2ban/action.d/cloudflare-docker.conf" ]; then
		CFmessage="режим cf включен"
	else
		CFmessage=""
	fi
}


nginx_http_on() {

local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
local ipv6_pattern='^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))))$'
if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
	sed -i '/if (\$scheme = http) {/,/}/s/^/#/' /home/web/conf.d/${yuming}.conf
fi

}


patch_wp_memory_limit() {
  local MEMORY_LIMIT="${1:-256M}"      # 第一个参数，默认256M
  local MAX_MEMORY_LIMIT="${2:-256M}"  # 第二个参数，默认256M
  local TARGET_DIR="/home/web/html"    # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# Удалить старое определение
	sed -i "/define(['\"]WP_MEMORY_LIMIT['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_MAX_MEMORY_LIMIT['\"].*/d" "$FILE"

	# Вставьте новое определение перед строкой, содержащей «Счастливой публикации».
	awk -v insert="define('WP_MEMORY_LIMIT', '$MEMORY_LIMIT');\ndefine('WP_MAX_MEMORY_LIMIT', '$MAX_MEMORY_LIMIT');" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_MEMORY_LIMIT in $FILE"
  done
}




patch_wp_debug() {
  local DEBUG="${1:-false}"           # 第一个参数，默认false
  local DEBUG_DISPLAY="${2:-false}"   # 第二个参数，默认false
  local DEBUG_LOG="${3:-false}"       # 第三个参数，默认false
  local TARGET_DIR="/home/web/html"   # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# Удалить старое определение
	sed -i "/define(['\"]WP_DEBUG['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_DISPLAY['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_LOG['\"].*/d" "$FILE"

	# Вставьте новое определение перед строкой, содержащей «Счастливой публикации».
	awk -v insert="define('WP_DEBUG_DISPLAY', $DEBUG_DISPLAY);\ndefine('WP_DEBUG_LOG', $DEBUG_LOG);" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_DEBUG settings in $FILE"
  done
}




patch_wp_url() {
  local HOME_URL="$1"
  local SITE_URL="$2"
  local TARGET_DIR="/home/web/html"

  find "$TARGET_DIR" -type f -name "wp-config-sample.php" | while read -r FILE; do
	# Удалить старое определение
	sed -i "/define(['\"]WP_HOME['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_SITEURL['\"].*/d" "$FILE"

	# Генерация вставки контента
	INSERT="
define('WP_HOME', '$HOME_URL');
define('WP_SITEURL', '$SITE_URL');
"

	# Вставьте перед «Счастливой публикации!»
	awk -v insert="$INSERT" '
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Updated WP_HOME and WP_SITEURL in $FILE"
  done
}








nginx_br() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# Включите Brotli: удалите комментарии
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# brotli on;|\1brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_static on;|\1brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_comp_level \(.*\);|\1brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_buffers \(.*\);|\1brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_min_length \(.*\);|\1brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_window \(.*\);|\1brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_types \(.*\);|\1brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf

	elif [ "$mode" == "off" ]; then
		# Закрыть Бротли: добавить комментарии
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)brotli on;|\1# brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_static on;|\1# brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_comp_level \(.*\);|\1# brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_buffers \(.*\);|\1# brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_min_length \(.*\);|\1# brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_window \(.*\);|\1# brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_types \(.*\);|\1# brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf

	else
		echo "Неверный аргумент: используйте «вкл» или «выкл»."
		return 1
	fi

	# Проверьте образ nginx и обработайте его соответствующим образом.
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi


}



nginx_zstd() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# Включите Zstd: удалите комментарии
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# zstd on;|\1zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_static on;|\1zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_comp_level \(.*\);|\1zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_buffers \(.*\);|\1zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_min_length \(.*\);|\1zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_types \(.*\);|\1zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf



	elif [ "$mode" == "off" ]; then
		# Закрыть Zstd: добавить комментарии
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)zstd on;|\1# zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_static on;|\1# zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_comp_level \(.*\);|\1# zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_buffers \(.*\);|\1# zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_min_length \(.*\);|\1# zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_types \(.*\);|\1# zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf


	else
		echo "Неверный аргумент: используйте «вкл» или «выкл»."
		return 1
	fi

	# Проверьте образ nginx и обработайте его соответствующим образом.
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi



}








nginx_gzip() {

	local mode=$1
	if [ "$mode" == "on" ]; then
		sed -i 's|^\(\s*\)# gzip on;|\1gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		sed -i 's|^\(\s*\)gzip on;|\1# gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "Неверный аргумент: используйте «вкл» или «выкл»."
		return 1
	fi

	docker exec nginx nginx -s reload

}






web_security() {
	  send_stats "Защита окружающей среды ЛДНМП"
	  while true; do
		check_f2b_status
		check_waf_status
		check_cf_mode
			  clear
			  echo -e "Программа защиты веб-сайта сервера${check_f2b_status}${gl_lv}${CFmessage}${waf_status}${gl_bai}"
			  echo "------------------------"
			  echo "1. Установите защитную программу"
			  echo "------------------------"
			  echo "5. Просмотр записей перехвата SSH 6. Просмотр записей перехвата веб-сайта"
			  echo "7. Просмотр списка правил защиты. 8. Просмотр журналов для мониторинга в реальном времени."
			  echo "------------------------"
			  echo "11. Настроить параметры перехвата 12. Очистить все заблокированные IP-адреса"
			  echo "------------------------"
			  echo "21. Режим Cloudflare 22. Включить щит на 5 секунд при высокой нагрузке"
			  echo "------------------------"
			  echo "31. Включите WAF 32. Выключите WAF"
			  echo "33. Включить защиту от DDOS 34. Выключить защиту от DDOS"
			  echo "------------------------"
			  echo "9. Удалите программу защиты."
			  echo "------------------------"
			  echo "0. Вернуться в предыдущее меню"
			  echo "------------------------"
			  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
			  case $sub_choice in
				  1)
					  f2b_install_sshd
					  cd /etc/fail2ban/filter.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/fail2ban-nginx-cc.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-418.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-deny.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-unauthorized.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-bad-request.conf

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/nginx-docker-cc.conf
					  sed -i "/cloudflare/d" /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  ;;
				  5)
					  echo "------------------------"
					  f2b_sshd
					  echo "------------------------"
					  ;;
				  6)

					  echo "------------------------"
					  local xxx="fail2ban-nginx-cc"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-418"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-bad-request"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-badbots"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-botsearch"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-deny"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-http-auth"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-unauthorized"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="php-url-fopen"
					  f2b_status_xxx
					  echo "------------------------"

					  ;;

				  7)
					  fail2ban-client status
					  ;;
				  8)
					  tail -f /var/log/fail2ban.log

					  ;;
				  9)
					  remove fail2ban
					  rm -rf /etc/fail2ban
					  crontab -l | grep -v "CF-Under-Attack.sh" | crontab - 2>/dev/null
					  echo "Защитная программа Fail2Ban удалена."
					  break
					  ;;

				  11)
					  install nano
					  nano /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  break
					  ;;

				  12)
					  fail2ban-client unban --all
					  ;;

				  21)
					  send_stats "режим облачной вспышки"
					  echo "Перейдите в мой профиль в правом верхнем углу серверной части cf, выберите токен API слева и получите глобальный ключ API."
					  echo "https://dash.cloudflare.com/login"
					  read -e -p "Введите номер счета CF:" cfuser
					  read -e -p "Введите глобальный ключ API CF:" cftoken

					  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/default11.conf
					  docker exec nginx nginx -s reload

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/nginx-docker-cc.conf

					  cd /etc/fail2ban/action.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/cloudflare-docker.conf

					  sed -i "s/kejilion@outlook.com/$cfuser/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  sed -i "s/APIKEY00000/$cftoken/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  f2b_status

					  echo "Режим Cloudflare настроен, и запись перехвата можно просмотреть в фоновом режиме cf, site-security-events."
					  ;;

				  22)
					  send_stats "Высокая нагрузка включает 5-секундный щит."
					  echo -e "${gl_huang}Веб-сайт автоматически обнаруживает каждые 5 минут. Когда он обнаруживает высокую нагрузку, он автоматически открывает экран, а когда он обнаруживает низкую нагрузку, он автоматически закрывает экран на 5 секунд.${gl_bai}"
					  echo "--------------"
					  echo "Получить параметры CF:"
					  echo -e "Перейдите в мой профиль в правом верхнем углу серверной части cf, выберите токен API слева и получите${gl_huang}Global API Key${gl_bai}"
					  echo -e "Перейдите в правый нижний угол страницы сводной информации о доменных именах CF, чтобы получить ее.${gl_huang}Идентификатор области${gl_bai}"
					  echo "https://dash.cloudflare.com/login"
					  echo "--------------"
					  read -e -p "Введите номер счета CF:" cfuser
					  read -e -p "Введите глобальный ключ API CF:" cftoken
					  read -e -p "Введите идентификатор зоны доменного имени в CF:" cfzonID

					  cd ~
					  install jq bc
					  check_crontab_installed
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/CF-Under-Attack.sh
					  chmod +x CF-Under-Attack.sh
					  sed -i "s/AAAA/$cfuser/g" ~/CF-Under-Attack.sh
					  sed -i "s/BBBB/$cftoken/g" ~/CF-Under-Attack.sh
					  sed -i "s/CCCC/$cfzonID/g" ~/CF-Under-Attack.sh

					  local cron_job="*/5 * * * * ~/CF-Under-Attack.sh"

					  local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

					  if [ -z "$existing_cron" ]; then
						  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
						  echo "Добавлен скрипт автоматического открытия щита при высокой нагрузке."
					  else
						  echo "Скрипт автоматического открытия щита уже существует, добавлять его не нужно."
					  fi

					  ;;

				  31)
					  nginx_waf on
					  echo "WAF сайта включен"
					  send_stats "WAF сайта включен"
					  ;;

				  32)
				  	  nginx_waf off
					  echo "Сайт WAF не работает"
					  send_stats "Сайт WAF не работает"
					  ;;

				  33)
					  enable_ddos_defense
					  ;;

				  34)
					  disable_ddos_defense
					  ;;

				  *)
					  break
					  ;;
			  esac
	  break_end
	  done
}



check_ldnmp_mode() {

	local MYSQL_CONTAINER="mysql"
	local MYSQL_CONF="/etc/mysql/conf.d/custom_mysql_config.cnf"

	# Проверьте, содержит ли файл конфигурации MySQL 4096M.
	if docker exec "$MYSQL_CONTAINER" grep -q "4096M" "$MYSQL_CONF" 2>/dev/null; then
		mode_info="Режим высокой производительности"
	else
		mode_info="Стандартный режим"
	fi



}


check_nginx_compression() {

	local CONFIG_FILE="/home/web/nginx.conf"

	# Проверьте, включен ли zstd и раскомментирован (вся строка начинается с включенного zstd;)
	if grep -qE '^\s*zstd\s+on;' "$CONFIG_FILE"; then
		zstd_status="сжатие zstd включено"
	else
		zstd_status=""
	fi

	# Проверьте, включен ли brotli и не раскомментирован
	if grep -qE '^\s*brotli\s+on;' "$CONFIG_FILE"; then
		br_status="brСжатие включено"
	else
		br_status=""
	fi

	# Проверьте, включен ли gzip и раскомментирован
	if grep -qE '^\s*gzip\s+on;' "$CONFIG_FILE"; then
		gzip_status="сжатие gzip включено"
	else
		gzip_status=""
	fi
}




web_optimization() {
		  while true; do
		  	  check_ldnmp_mode
			  check_nginx_compression
			  clear
			  send_stats "Оптимизация среды LDNMP"
			  echo -e "Оптимизация среды LDNMP${gl_lv}${mode_info}${gzip_status}${br_status}${zstd_status}${gl_bai}"
			  echo "------------------------"
			  echo "1. Стандартный режим 2. Режим высокой производительности (рекомендуется 2H4G или выше)"
			  echo "------------------------"
			  echo "3. Включите сжатие gzip 4. Отключите сжатие gzip"
			  echo "5. Включите сжатие br. 6. Выключите сжатие br."
			  echo "7. Включите сжатие zstd 8. Отключите сжатие zstd"
			  echo "------------------------"
			  echo "0. Вернуться в предыдущее меню"
			  echo "------------------------"
			  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
			  case $sub_choice in
				  1)
				  send_stats "режим стандартов сайта"

				  local cpu_cores=$(nproc)
				  local connections=$((1024 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf


				  # настройка PHP
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # настройка PHP
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/www-1.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # настройка MySQL
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config-1.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf


				  cd /home/web && docker compose restart

				  optimize_balanced


				  echo "Среда LDNMP переведена в стандартный режим."

					  ;;
				  2)
				  send_stats "Режим высокой производительности сайта"

				  # настройка nginx
				  local cpu_cores=$(nproc)
				  local connections=$((2048 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf

				  # настройка PHP
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # настройка PHP
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/www.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit 512M 512M
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # настройка MySQL
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf

				  cd /home/web && docker compose restart

				  optimize_web_server

				  echo "Среда LDNMP переведена в режим высокой производительности."

					  ;;
				  3)
				  send_stats "nginx_gzip on"
				  nginx_gzip on
					  ;;
				  4)
				  send_stats "nginx_gzip off"
				  nginx_gzip off
					  ;;
				  5)
				  send_stats "nginx_br on"
				  nginx_br on
					  ;;
				  6)
				  send_stats "nginx_br off"
				  nginx_br off
					  ;;
				  7)
				  send_stats "nginx_zstd on"
				  nginx_zstd on
					  ;;
				  8)
				  send_stats "nginx_zstd off"
				  nginx_zstd off
					  ;;
				  *)
					  break
					  ;;
			  esac
			  break_end

		  done


}










check_docker_app() {
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name" ; then
		check_docker="${gl_lv}Установлено${gl_bai}"
	else
		check_docker="${gl_hui}Не установлено${gl_bai}"
	fi
}



# check_docker_app() {

# if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
# check_docker="${gl_lv} установил ${gl_bai}"
# else
# check_docker="${gl_hui} не установлен ${gl_bai}"
# fi

# }


check_docker_app_ip() {
echo "------------------------"
echo "Адрес посещения:"
ip_address



if [ -n "$ipv4_address" ]; then
	echo "http://$ipv4_address:${docker_port}"
fi

if [ -n "$ipv6_address" ]; then
	echo "http://[$ipv6_address]:${docker_port}"
fi

local search_pattern1="$ipv4_address:${docker_port}"
local search_pattern2="127.0.0.1:${docker_port}"

for file in /home/web/conf.d/*; do
	if [ -f "$file" ]; then
		if grep -q "$search_pattern1" "$file" 2>/dev/null || grep -q "$search_pattern2" "$file" 2>/dev/null; then
			echo "https://$(basename "$file" | sed 's/\.conf$//')"
		fi
	fi
done


}


check_docker_image_update() {
	local container_name=$1
	update_status=""

	# 1. Региональная инспекция
	local country=$(curl -s --max-time 2 ipinfo.io/country)
	[[ "$country" == "CN" ]] && return

	# 2. Получите информацию о локальном зеркале
	local container_info=$(docker inspect --format='{{.Created}},{{.Config.Image}}' "$container_name" 2>/dev/null)
	[[ -z "$container_info" ]] && return

	local container_created=$(echo "$container_info" | cut -d',' -f1)
	local full_image_name=$(echo "$container_info" | cut -d',' -f2)
	local container_created_ts=$(date -d "$container_created" +%s 2>/dev/null)

	# 3. Интеллектуальная маршрутизация
	if [[ "$full_image_name" == ghcr.io* ]]; then
		# --- Сценарий А: зеркало на GitHub (ghcr.io) ---
		# Извлеките путь к складу, например ghcr.io/onexru/oneimg -> onexru/oneimg.
		local repo_path=$(echo "$full_image_name" | sed 's/ghcr.io\///' | cut -d':' -f1)
		# Примечание. API ghcr.io относительно сложен. Обычно самый быстрый способ — проверить выпуск репозитория GitHub.
		local api_url="https://api.github.com/repos/$repo_path/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	elif [[ "$full_image_name" == *"oneimg"* ]]; then
		# --- Сценарий Б: Специальное обозначение (даже в Docker Hub, хочу судить по GitHub Release) ---
		local api_url="https://api.github.com/repos/onexru/oneimg/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	else
		# --- Сценарий C: Стандартный Docker Hub ---
		local image_repo=${full_image_name%%:*}
		local image_tag=${full_image_name##*:}
		[[ "$image_repo" == "$image_tag" ]] && image_tag="latest"
		[[ "$image_repo" != */* ]] && image_repo="library/$image_repo"

		local api_url="https://hub.docker.com/v2/repositories/$image_repo/tags/$image_tag"
		local remote_date=$(curl -s "$api_url" | jq -r '.last_updated' 2>/dev/null)
	fi

	# 4. Сравнение временных меток
	if [[ -n "$remote_date" && "$remote_date" != "null" ]]; then
		local remote_ts=$(date -d "$remote_date" +%s 2>/dev/null)
		if [[ $container_created_ts -lt $remote_ts ]]; then
			update_status="${gl_huang}Найдена новая версия!${gl_bai}"
		fi
	fi
}







block_container_port() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# Получить IP-адрес контейнера
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# Проверьте и заблокируйте все остальные IP-адреса.
	if ! iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# Проверьте и освободите указанный IP
	if ! iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# Проверьте и разрешите локальную сеть 127.0.0.0/8.
	if ! iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi



	# Проверьте и заблокируйте все остальные IP-адреса.
	if ! iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# Проверьте и освободите указанный IP
	if ! iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# Проверьте и разрешите локальную сеть 127.0.0.0/8.
	if ! iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi

	if ! iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "IP+порт заблокирован для доступа к сервису"
	save_iptables_rules
}




clear_container_rules() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# Получить IP-адрес контейнера
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# Четкие правила, которые блокируют все остальные IP-адреса
	if iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# Очистите правила, разрешающие указанные IP-адреса.
	if iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# Очистите правила, разрешающие локальную сеть 127.0.0.0/8.
	if iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi





	# Четкие правила, которые блокируют все остальные IP-адреса
	if iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# Очистите правила, разрешающие указанные IP-адреса.
	if iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# Очистите правила, разрешающие локальную сеть 127.0.0.0/8.
	if iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi


	if iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "IP+порту разрешен доступ к сервису"
	save_iptables_rules
}






block_host_port() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "Ошибка: Укажите номер порта и IP-адрес, чтобы разрешить доступ."
		echo "Использование: block_host_port <номер порта> <разрешенный IP>"
		return 1
	fi

	install iptables


	# Запретить доступ со всех остальных IP-адресов
	if ! iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -j DROP
	fi

	# Разрешить доступ к указанному IP
	if ! iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# Разрешить локальный доступ
	if ! iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi





	# Запретить доступ со всех остальных IP-адресов
	if ! iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -j DROP
	fi

	# Разрешить доступ к указанному IP
	if ! iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# Разрешить локальный доступ
	if ! iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# Разрешить трафик для установленных и связанных соединений
	if ! iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT &>/dev/null; then
		iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	fi

	echo "IP+порт заблокирован для доступа к сервису"
	save_iptables_rules
}




clear_host_port_rules() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "Ошибка: Укажите номер порта и IP-адрес, чтобы разрешить доступ."
		echo "Использование:clear_host_port_rules <номер порта> <разрешенный IP>"
		return 1
	fi

	install iptables


	# Очистите правило, блокирующее доступ со всех остальных IP-адресов.
	if iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -j DROP
	fi

	# Четкие правила, разрешающие локальный доступ
	if iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# Четкие правила, разрешающие доступ с определенных IP-адресов.
	if iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	# Очистите правило, блокирующее доступ со всех остальных IP-адресов.
	if iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -j DROP
	fi

	# Четкие правила, разрешающие локальный доступ
	if iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# Четкие правила, разрешающие доступ с определенных IP-адресов.
	if iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	echo "IP+порту разрешен доступ к сервису"
	save_iptables_rules

}



setup_docker_dir() {

	mkdir -p /home /home/docker 2>/dev/null

	if [ -d "/vol1/1000/" ] && [ ! -d "/vol1/1000/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /vol1/1000/docker 2>/dev/null
		ln -s /vol1/1000/docker /home/docker 2>/dev/null
	fi

	if [ -d "/volume1/" ] && [ ! -d "/volume1/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /volume1/docker 2>/dev/null
		ln -s /volume1/docker /home/docker 2>/dev/null
	fi


}


add_app_id() {
mkdir -p /home/docker
touch /home/docker/appno.txt
grep -qxF "${app_id}" /home/docker/appno.txt || echo "${app_id}" >> /home/docker/appno.txt

}



docker_app() {
send_stats "${docker_name}управлять"

while true; do
	clear
	check_docker_app
	check_docker_image_update $docker_name
	echo -e "$docker_name $check_docker $update_status"
	echo "$docker_describe"
	echo "$docker_url"
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
		if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
			local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
			docker_port=${docker_port:-0000}
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
		fi
		local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
		check_docker_app_ip
	fi
	echo ""
	echo "------------------------"
	echo "1. Установить 2. Обновить 3. Удалить"
	echo "------------------------"
	echo "5. Добавить доступ к доменному имени 6. Удалить доступ к доменному имени"
	echo "7. Разрешить доступ по IP+порту. 8. Заблокировать доступ по IP+порту."
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" choice
	 case $choice in
		1)
			setup_docker_dir
			check_disk_space $app_size /home/docker
			while true; do
				read -e -p "Введите порт внешней службы приложения и нажмите Enter, чтобы использовать его по умолчанию.${docker_port}порт:" app_port
				local app_port=${app_port:-${docker_port}}

				if ss -tuln | grep -q ":$app_port "; then
					echo -e "${gl_hong}ошибка:${gl_bai}порт$app_portУже занято, пожалуйста, измените порт"
					send_stats "Порт приложения занят"
				else
					local docker_port=$app_port
					break
				fi
			done

			install jq
			install_docker
			docker_rum
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

			add_app_id

			clear
			echo "$docker_nameУстановка завершена"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "Установить$docker_name"
			;;
		2)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			docker_rum

			add_app_id

			clear
			echo "$docker_nameУстановка завершена"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "возобновлять$docker_name"
			;;
		3)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			rm -rf "/home/docker/$docker_name"
			rm -f /home/docker/${docker_name}_port.conf

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			echo "Приложение удалено"
			send_stats "удалить$docker_name"
			;;

		5)
			echo "${docker_name}Настройки доступа к доменному имени"
			send_stats "${docker_name}Настройки доступа к доменному имени"
			add_yuming
			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"
			;;

		6)
			echo "Формат доменного имени example.com без https://"
			web_del
			;;

		7)
			send_stats "Разрешить доступ по IP${docker_name}"
			clear_container_rules "$docker_name" "$ipv4_address"
			;;

		8)
			send_stats "Заблокировать доступ по IP${docker_name}"
			block_container_port "$docker_name" "$ipv4_address"
			;;

		*)
			break
			;;
	 esac
	 break_end
done

}





docker_app_plus() {
	send_stats "$app_name"
	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "$app_name $check_docker $update_status"
		echo "$app_text"
		echo "$app_url"
		if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
			if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
				local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
				docker_port=${docker_port:-0000}
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
			fi
			local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
			check_docker_app_ip
		fi
		echo ""
		echo "------------------------"
		echo "1. Установить 2. Обновить 3. Удалить"
		echo "------------------------"
		echo "5. Добавить доступ к доменному имени 6. Удалить доступ к доменному имени"
		echo "7. Разрешить доступ по IP+порту. 8. Заблокировать доступ по IP+порту."
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Введите свой выбор:" choice
		case $choice in
			1)
				setup_docker_dir
				check_disk_space $app_size /home/docker

				while true; do
					read -e -p "Введите порт внешней службы приложения и нажмите Enter, чтобы использовать его по умолчанию.${docker_port}порт:" app_port
					local app_port=${app_port:-${docker_port}}

					if ss -tuln | grep -q ":$app_port "; then
						echo -e "${gl_hong}ошибка:${gl_bai}порт$app_portУже занято, пожалуйста, измените порт"
						send_stats "Порт приложения занят"
					else
						local docker_port=$app_port
						break
					fi
				done

				install jq
				install_docker
				docker_app_install
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

				add_app_id
				send_stats "$app_nameУстановить"
				;;

			2)
				docker_app_update
				add_app_id
				send_stats "$app_nameвозобновлять"
				;;

			3)
				docker_app_uninstall
				rm -f /home/docker/${docker_name}_port.conf

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				send_stats "$app_nameудалить"
				;;

			5)
				echo "${docker_name}Настройки доступа к доменному имени"
				send_stats "${docker_name}Настройки доступа к доменному имени"
				add_yuming
				ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
				block_container_port "$docker_name" "$ipv4_address"

				;;
			6)
				echo "Формат доменного имени example.com без https://"
				web_del
				;;
			7)
				send_stats "Разрешить доступ по IP${docker_name}"
				clear_container_rules "$docker_name" "$ipv4_address"
				;;
			8)
				send_stats "Заблокировать доступ по IP${docker_name}"
				block_container_port "$docker_name" "$ipv4_address"
				;;
			*)
				break
				;;
		esac
		break_end
	done
}





prometheus_install() {

local PROMETHEUS_DIR="/home/docker/monitoring/prometheus"
local GRAFANA_DIR="/home/docker/monitoring/grafana"
local NETWORK_NAME="monitoring"

# Create necessary directories
mkdir -p $PROMETHEUS_DIR
mkdir -p $GRAFANA_DIR

# Set correct ownership for Grafana directory
chown -R 472:472 $GRAFANA_DIR

if [ ! -f "$PROMETHEUS_DIR/prometheus.yml" ]; then
	curl -o "$PROMETHEUS_DIR/prometheus.yml" ${gh_proxy}raw.githubusercontent.com/kejilion/config/refs/heads/main/prometheus/prometheus.yml
fi

# Create Docker network for monitoring
docker network create $NETWORK_NAME

# Run Node Exporter container
docker run -d \
  --name=node-exporter \
  --network $NETWORK_NAME \
  --restart=always \
  prom/node-exporter

# Run Prometheus container
docker run -d \
  --name prometheus \
  -v $PROMETHEUS_DIR/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $PROMETHEUS_DIR/data:/prometheus \
  --network $NETWORK_NAME \
  --restart=always \
  --user 0:0 \
  prom/prometheus:latest

# Run Grafana container
docker run -d \
  --name grafana \
  -p ${docker_port}:3000 \
  -v $GRAFANA_DIR:/var/lib/grafana \
  --network $NETWORK_NAME \
  --restart=always \
  grafana/grafana:latest

}




tmux_run() {
	# Check if the session already exists
	tmux has-session -t $SESSION_NAME 2>/dev/null
	# $? is a special variable that holds the exit status of the last executed command
	if [ $? != 0 ]; then
	  # Session doesn't exist, create a new one
	  tmux new -s $SESSION_NAME
	else
	  # Session exists, attach to it
	  tmux attach-session -t $SESSION_NAME
	fi
}


tmux_run_d() {

local base_name="tmuxd"
local tmuxd_ID=1

# Функция проверки существования сеанса
session_exists() {
  tmux has-session -t $1 2>/dev/null
}

# Цикл, пока не будет найдено имя несуществующего сеанса.
while session_exists "$base_name-$tmuxd_ID"; do
  local tmuxd_ID=$((tmuxd_ID + 1))
done

# Создайте новый сеанс tmux
tmux new -d -s "$base_name-$tmuxd_ID" "$tmuxd"


}



f2b_status() {
	 fail2ban-client reload
	 sleep 3
	 fail2ban-client status
}

f2b_status_xxx() {
	fail2ban-client status $xxx
}

check_f2b_status() {
	if command -v fail2ban-client >/dev/null 2>&1; then
		check_f2b_status="${gl_lv}Установлено${gl_bai}"
	else
		check_f2b_status="${gl_hui}Не установлено${gl_bai}"
	fi
}

f2b_install_sshd() {

	docker rm -f fail2ban >/dev/null 2>&1
	install fail2ban
	start fail2ban
	enable fail2ban

	if command -v dnf &>/dev/null; then
		cd /etc/fail2ban/jail.d/
		curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/centos-ssh.conf
	fi

	if command -v apt &>/dev/null; then
		install rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
	fi

}

f2b_sshd() {
	if grep -q 'Alpine' /etc/issue; then
		xxx=alpine-sshd
		f2b_status_xxx
	else
		xxx=sshd
		f2b_status_xxx
	fi
}




server_reboot() {

	read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}现在重启服务器吗？(Y/N): ")" rboot
	case "$rboot" in
	  [Yy])
		echo "Перезапущен"
		reboot
		;;
	  *)
		echo "Отменено"
		;;
	esac


}





output_status() {
	output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
		$1 ~ /^(eth|ens|enp|eno)[0-9]+/ {
			rx_total += $2
			tx_total += $10
		}
		END {
			rx_units = "Bytes";
			tx_units = "Bytes";
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "K"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "M"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "G"; }

			if (tx_total > 1024) { tx_total /= 1024; tx_units = "K"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "M"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "G"; }

			printf("%.2f%s %.2f%s\n", rx_total, rx_units, tx_total, tx_units);
		}' /proc/net/dev)

	rx=$(echo "$output" | awk '{print $1}')
	tx=$(echo "$output" | awk '{print $2}')

}




ldnmp_install_status_one() {

   if docker inspect "php" &>/dev/null; then
	clear
	send_stats "Невозможно снова установить среду LDNMP."
	echo -e "${gl_huang}намекать:${gl_bai}Среда создания веб-сайта установлена. Нет необходимости устанавливать снова!"
	break_end
	linux_ldnmp
   fi

}


ldnmp_install_all() {
cd ~
send_stats "Установите среду LDNMP"
root_use
clear
echo -e "${gl_huang}Среда LDNMP не установлена. Начните установку среды LDNMP...${gl_bai}"
check_disk_space 3 /home
install_dependency
install_docker
install_certbot
install_ldnmp_conf
install_ldnmp

}


nginx_install_all() {
cd ~
send_stats "Установите среду nginx"
root_use
clear
echo -e "${gl_huang}nginx не установлен, начните установку среды nginx...${gl_bai}"
check_disk_space 1 /home
install_dependency
install_docker
install_certbot
install_ldnmp_conf
nginx_upgrade
clear
local nginx_version=$(docker exec nginx nginx -v 2>&1)
local nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
echo "nginx установлен"
echo -e "Текущая версия:${gl_huang}v$nginx_version${gl_bai}"
echo ""

}




ldnmp_install_status() {

	if ! docker inspect "php" &>/dev/null; then
		send_stats "Сначала установите среду LDNMP"
		ldnmp_install_all
	fi

}


nginx_install_status() {

	if ! docker inspect "nginx" &>/dev/null; then
		send_stats "Пожалуйста, сначала установите среду nginx"
		nginx_install_all
	fi

}




ldnmp_web_on() {
	  clear
	  echo "твой$webnameОн построен!"
	  echo "https://$yuming"
	  echo "------------------------"
	  echo "$webnameИнформация об установке следующая:"

}

nginx_web_on() {
	clear

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	echo "твой$webnameОн построен!"

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		mv /home/web/conf.d/"$yuming".conf /home/web/conf.d/"${yuming}_${access_port}".conf
		echo "http://$yuming:$access_port"
	elif grep -q '^[[:space:]]*#.*if (\$scheme = http)' "/home/web/conf.d/"$yuming".conf"; then
		echo "http://$yuming"
	else
		echo "https://$yuming"
	fi
}



ldnmp_wp() {
  clear
  # wordpress
  webname="WordPress"
  yuming="${1:-}"
  send_stats "Установить$webname"
  echo "Начать развертывание$webname"
  if [ -z "$yuming" ]; then
	add_yuming
  fi
  repeat_add_yuming
  ldnmp_install_status


  install_ssltls
  certs_status
  add_db

  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/wordpress.com.conf
  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
  nginx_http_on


  cd /home/web/html
  mkdir $yuming
  cd $yuming
  wget -O latest.zip ${gh_proxy}github.com/kejilion/Website_source_code/raw/refs/heads/main/wp-latest.zip
  unzip latest.zip
  rm latest.zip
  echo "define('FS_METHOD', 'direct'); define('WP_REDIS_HOST', 'redis'); define('WP_REDIS_PORT', '6379'); define('WP_REDIS_MAXTTL', 86400); define('WP_CACHE_KEY_SALT', '${yuming}_');" >> /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|database_name_here|$dbname|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|username_here|$dbuse|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|password_here|$dbusepasswd|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|localhost|mysql|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  patch_wp_url "https://$yuming" "https://$yuming"
  cp /home/web/html/$yuming/wordpress/wp-config-sample.php /home/web/html/$yuming/wordpress/wp-config.php


  restart_ldnmp
  nginx_web_on

}



ldnmp_Proxy() {
	clear
	webname="Обратный прокси-IP+порт"
	yuming="${1:-}"
	reverseproxy="${2:-}"
	port="${3:-}"

	send_stats "Установить$webname"
	echo "Начать развертывание$webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy" ]; then
		read -e -p "Пожалуйста, введите свой IP-адрес для предотвращения генерации (нажмите Enter, чтобы по умолчанию использовать локальный IP-адрес 127.0.0.1):" reverseproxy
		reverseproxy=${reverseproxy:-127.0.0.1}
	fi

	if [ -z "$port" ]; then
		read -e -p "Пожалуйста, введите свой порт антигенерации:" port
	fi
	nginx_install_status


	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	reverseproxy_port="$reverseproxy:$port"
	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# динамически добавлять/$upstream_servers/g" /home/web/conf.d/$yuming.conf
	sed -i '/remote_addr/d' /home/web/conf.d/$yuming.conf

	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}



ldnmp_Proxy_backend() {
	clear
	webname="Балансировка нагрузки обратного прокси-сервера"

	send_stats "Установить$webname"
	echo "Начать развертывание$webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy_port" ]; then
		read -e -p "Введите несколько IP+портов для предотвращения генерации, разделенных пробелами (например, 127.0.0.1:3000 127.0.0.1:3002):" reverseproxy_port
	fi

	nginx_install_status

	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# динамически добавлять/$upstream_servers/g" /home/web/conf.d/$yuming.conf


	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}






list_stream_services() {

	STREAM_DIR="/home/web/stream.d"
	printf "%-25s %-18s %-25s %-20s\n" "Название службы" "Тип связи" "местный адрес" "Внутренний адрес"

	if [ -z "$(ls -A "$STREAM_DIR")" ]; then
		return
	fi

	for conf in "$STREAM_DIR"/*; do
		# Имя службы принимает имя файла
		service_name=$(basename "$conf" .conf)

		# Получите IP-адрес серверной части сервера в восходящем блоке.
		backend=$(grep -Po '(?<=server )[^;]+' "$conf" | head -n1)

		# Получить порт прослушивания
		listen_port=$(grep -Po '(?<=listen )[^;]+' "$conf" | head -n1)

		# Локальный IP-адрес по умолчанию
		ip_address
		local_ip="$ipv4_address"

		# Получите тип связи, сначала судя по суффиксу имени файла или содержимому.
		if grep -qi 'udp;' "$conf"; then
			proto="udp"
		else
			proto="tcp"
		fi

		# IP-адрес прослушивания соединения: порт
		local_addr="$local_ip:$listen_port"

		printf "%-22s %-14s %-21s %-20s\n" "$service_name" "$proto" "$local_addr" "$backend"
	done
}









stream_panel() {
	send_stats "Потоковый четырехуровневый прокси"
	local app_id="104"
	local docker_name="nginx"

	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "Инструмент четырехуровневой переадресации прокси-сервера Stream$check_docker $update_status"
		echo "NGINX Stream — это прокси-модуль TCP/UDP NGINX, который используется для обеспечения высокопроизводительной пересылки трафика транспортного уровня и балансировки нагрузки."
		echo "------------------------"
		if [ -d "/home/web/stream.d" ]; then
			list_stream_services
		fi
		echo ""
		echo "------------------------"
		echo "1. Установить 2. Обновить 3. Удалить"
		echo "------------------------"
		echo "4. Добавить службу переадресации 5. Изменить службу переадресации 6. Удалить службу переадресации"
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Введите свой выбор:" choice
		case $choice in
			1)
				nginx_install_status
				add_app_id
				send_stats "Установите четырехуровневый агент Stream"
				;;
			2)
				update_docker_compose_with_db_creds
				nginx_upgrade
				add_app_id
				send_stats "Обновить четырехуровневый прокси Stream"
				;;
			3)
				read -e -p "Вы уверены, что хотите удалить контейнер nginx? Это может повлиять на функциональность сайта! (да/нет):" confirm
				if [[ "$confirm" =~ ^[Yy]$ ]]; then
					docker rm -f nginx
					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					send_stats "Обновить четырехуровневый прокси Stream"
					echo "Контейнер nginx был удален."
				else
					echo "Операция отменена."
				fi

				;;

			4)
				ldnmp_Proxy_backend_stream
				add_app_id
				send_stats "Добавить прокси уровня 4"
				;;
			5)
				send_stats "Изменить конфигурацию переадресации"
				read -e -p "Введите название услуги, которую хотите изменить:" stream_name
				install nano
				nano /home/web/stream.d/$stream_name.conf
				docker restart nginx
				send_stats "Изменить прокси уровня 4"
				;;
			6)
				send_stats "Удалить конфигурацию переадресации"
				read -e -p "Пожалуйста, введите название службы, которую вы хотите удалить:" stream_name
				rm /home/web/stream.d/$stream_name.conf > /dev/null 2>&1
				docker restart nginx
				send_stats "Удалить прокси уровня 4"
				;;
			*)
				break
				;;
		esac
		break_end
	done
}



ldnmp_Proxy_backend_stream() {
	clear
	webname="Потоковая четырехуровневая балансировка нагрузки прокси-сервера"

	send_stats "Установить$webname"
	echo "Начать развертывание$webname"

	# Получить имя агента
	read -erp "Введите имя переадресации прокси-сервера (например, mysql_proxy):" proxy_name
	if [ -z "$proxy_name" ]; then
		echo "Имя не может быть пустым"; return 1
	fi

	# Получить порт прослушивания
	read -erp "Пожалуйста, введите локальный порт прослушивания (например, 3306):" listen_port
	if ! [[ "$listen_port" =~ ^[0-9]+$ ]]; then
		echo "Порт должен быть числовым"; return 1
	fi

	echo "Пожалуйста, выберите тип соглашения:"
	echo "1. TCP    2. UDP"
	read -erp "Пожалуйста, введите серийный номер [1-2]:" proto_choice

	case "$proto_choice" in
		1) proto="tcp"; listen_suffix="" ;;
		2) proto="udp"; listen_suffix=" udp" ;;
		*) echo "Неверный выбор"; return 1 ;;
	esac

	read -e -p "Введите один или несколько внутренних IP+портов, разделенных пробелами (например, 10.13.0.2:3306 10.13.0.3:3306):" reverseproxy_port

	nginx_install_status
	cd /home && mkdir -p web/stream.d
	grep -q '^[[:space:]]*stream[[:space:]]*{' /home/web/nginx.conf || echo -e '\nstream {\n    include /etc/nginx/stream.d/*.conf;\n}' | tee -a /home/web/nginx.conf
	wget -O /home/web/stream.d/$proxy_name.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend-stream.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/${proxy_name}_${backend}/g" /home/web/stream.d/"$proxy_name".conf
	sed -i "s|listen 80|listen $listen_port $listen_suffix|g" /home/web/stream.d/$proxy_name.conf
	sed -i "s|listen \[::\]:|listen [::]:${listen_port} ${listen_suffix}|g" "/home/web/stream.d/${proxy_name}.conf"

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# динамически добавлять/$upstream_servers/g" /home/web/stream.d/$proxy_name.conf

	docker exec nginx nginx -s reload
	clear
	echo "твой$webnameОн построен!"
	echo "------------------------"
	echo "Адрес посещения:"
	ip_address
	if [ -n "$ipv4_address" ]; then
		echo "$ipv4_address:${listen_port}"
	fi
	if [ -n "$ipv6_address" ]; then
		echo "$ipv6_address:${listen_port}"
	fi
	echo ""
}





find_container_by_host_port() {
	port="$1"
	docker_name=$(docker ps --format '{{.ID}} {{.Names}}' | while read id name; do
		if docker port "$id" | grep -q ":$port"; then
			echo "$name"
			break
		fi
	done)
}




ldnmp_web_status() {
	root_use
	while true; do
		local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
		local output="${gl_lv}${cert_count}${gl_bai}"

		local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
		local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
		local db_output="${gl_lv}${db_count}${gl_bai}"

		clear
		send_stats "Управление сайтом ЛДНМП"
		echo "среда LDNMP"
		echo "------------------------"
		ldnmp_v

		echo -e "Сайт:${output}Срок действия сертификата"
		echo -e "------------------------"
		for cert_file in /home/web/certs/*_cert.pem; do
		  local domain=$(basename "$cert_file" | sed 's/_cert.pem//')
		  if [ -n "$domain" ]; then
			local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
			local formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
			printf "%-30s%s\n" "$domain" "$formatted_date"
		  fi
		done

		for conf_file in /home/web/conf.d/*_*.conf; do
		  [ -e "$conf_file" ] || continue
		  basename "$conf_file" .conf
		done

		for conf_file in /home/web/conf.d/*.conf; do
		  [ -e "$conf_file" ] || continue

		  filename=$(basename "$conf_file")

		  if [ "$filename" = "map.conf" ] || [ "$filename" = "default.conf" ]; then
			continue
		  fi

		  if ! grep -q "ssl_certificate" "$conf_file"; then
			basename "$conf_file" .conf
		  fi
		done

		echo "------------------------"
		echo ""
		echo -e "база данных:${db_output}"
		echo -e "------------------------"
		local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys"

		echo "------------------------"
		echo ""
		echo "каталог сайта"
		echo "------------------------"
		echo -e "данные${gl_hui}/home/web/html${gl_bai}Сертификат${gl_hui}/home/web/certs${gl_bai}Конфигурация${gl_hui}/home/web/conf.d${gl_bai}"
		echo "------------------------"
		echo ""
		echo "действовать"
		echo "------------------------"
		echo "1. Примените/обновите сертификат доменного имени. 2. Клонируйте доменное имя сайта."
		echo "3. Очистить кеш сайта. 4. Создать связанный сайт."
		echo "5. Просмотр журнала доступа 6. Просмотр журнала ошибок"
		echo "7. Редактировать глобальную конфигурацию 8. Редактировать конфигурацию сайта"
		echo "9. Управление базой данных сайта. 10. Просмотр отчетов по анализу сайта."
		echo "------------------------"
		echo "20. Удалить указанные данные сайта."
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
		case $sub_choice in
			1)
				send_stats "Подать заявку на сертификат доменного имени"
				read -e -p "Пожалуйста, введите имя вашего домена:" yuming
				install_certbot
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
				install_ssltls
				certs_status

				;;

			2)
				send_stats "Клонировать доменное имя сайта"
				read -e -p "Пожалуйста, введите старое доменное имя:" oddyuming
				read -e -p "Пожалуйста, введите новое доменное имя:" yuming
				install_certbot
				install_ssltls
				certs_status


				add_db
				local odd_dbname=$(echo "$oddyuming" | sed -e 's/[^A-Za-z0-9]/_/g')
				local odd_dbname="${odd_dbname}"

				docker exec mysql mysqldump -u root -p"$dbrootpasswd" $odd_dbname | docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname

				local tables=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW TABLES;" | awk '{ if (NR>1) print $1 }')
				for table in $tables; do
					columns=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW COLUMNS FROM $table;" | awk '{ if (NR>1) print $1 }')
					for column in $columns; do
						docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "UPDATE $table SET $column = REPLACE($column, '$oddyuming', '$yuming') WHERE $column LIKE '%$oddyuming%';"
					done
				done

				# Замена каталога сайта
				cp -r /home/web/html/$oddyuming /home/web/html/$yuming

				find /home/web/html/$yuming -type f -exec sed -i "s/$odd_dbname/$dbname/g" {} +
				find /home/web/html/$yuming -type f -exec sed -i "s/$oddyuming/$yuming/g" {} +

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s/$oddyuming/$yuming/g" /home/web/conf.d/$yuming.conf

				cd /home/web && docker compose restart

				;;


			3)
				web_cache
				;;
			4)
				send_stats "Создание связанных сайтов"
				echo -e "Свяжите новое доменное имя с существующим сайтом для доступа"
				read -e -p "Пожалуйста, введите существующее доменное имя:" oddyuming
				read -e -p "Пожалуйста, введите новое доменное имя:" yuming
				install_certbot
				install_ssltls
				certs_status

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s|server_name $oddyuming|server_name $yuming|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_cert.pem|/etc/nginx/certs/${yuming}_cert.pem|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_key.pem|/etc/nginx/certs/${yuming}_key.pem|g" /home/web/conf.d/$yuming.conf

				docker exec nginx nginx -s reload

				;;
			5)
				send_stats "Посмотреть журнал доступа"
				tail -n 200 /home/web/log/nginx/access.log
				break_end
				;;
			6)
				send_stats "Посмотреть журнал ошибок"
				tail -n 200 /home/web/log/nginx/error.log
				break_end
				;;
			7)
				send_stats "Редактировать глобальную конфигурацию"
				install nano
				nano /home/web/nginx.conf
				docker exec nginx nginx -s reload
				;;

			8)
				send_stats "Изменить конфигурацию сайта"
				read -e -p "Чтобы изменить конфигурацию сайта, введите доменное имя, которое вы хотите изменить:" yuming
				install nano
				nano /home/web/conf.d/$yuming.conf
				docker exec nginx nginx -s reload
				;;
			9)
				phpmyadmin_upgrade
				break_end
				;;
			10)
				send_stats "Просмотр данных сайта"
				install goaccess
				goaccess --log-format=COMBINED /home/web/log/nginx/access.log
				;;

			20)
				web_del
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null

				;;
			*)
				break  # 跳出循环，退出菜单
				;;
		esac
	done


}


check_panel_app() {
if $lujing > /dev/null 2>&1; then
	check_panel="${gl_lv}Установлено${gl_bai}"
else
	check_panel=""
fi
}



install_panel() {
send_stats "${panelname}управлять"
while true; do
	clear
	check_panel_app
	echo -e "$panelname $check_panel"
	echo "${panelname}Это популярная и мощная панель управления эксплуатацией и обслуживанием."
	echo "Официальный сайт: введение:$panelurl "

	echo ""
	echo "------------------------"
	echo "1. Установить 2. Управление 3. Удалить"
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" choice
	 case $choice in
		1)
			check_disk_space 1
			install wget
			iptables_open
			panel_app_install

			add_app_id
			send_stats "${panelname}Установить"
			;;
		2)
			panel_app_manage

			add_app_id
			send_stats "${panelname}контроль"

			;;
		3)
			panel_app_uninstall

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			send_stats "${panelname}удалить"
			;;
		*)
			break
			;;
	 esac
	 break_end
done

}



check_frp_app() {

if [ -d "/home/frp/" ]; then
	check_frp="${gl_lv}Установлено${gl_bai}"
else
	check_frp="${gl_hui}Не установлено${gl_bai}"
fi

}



donlond_frp() {
  role="$1"
  config_file="/home/frp/${role}.toml"

  docker run -d \
	--name "$role" \
	--restart=always \
	--network host \
	-v "$config_file":"/frp/${role}.toml" \
	kjlion/frp:alpine \
	"/frp/${role}" -c "/frp/${role}.toml"

}




generate_frps_config() {

	send_stats "Установить frp-сервер"
	# Генерация случайных портов и учетных данных
	local bind_port=8055
	local dashboard_port=8056
	local token=$(openssl rand -hex 16)
	local dashboard_user="user_$(openssl rand -hex 4)"
	local dashboard_pwd=$(openssl rand -hex 8)

	mkdir -p /home/frp
	touch /home/frp/frps.toml
	cat <<EOF > /home/frp/frps.toml
[common]
bind_port = $bind_port
authentication_method = token
token = $token
dashboard_port = $dashboard_port
dashboard_user = $dashboard_user
dashboard_pwd = $dashboard_pwd
EOF

	donlond_frp frps

	# Вывод сгенерированной информации
	ip_address
	echo "------------------------"
	echo "Параметры, необходимые для развертывания клиента"
	echo "IP сервиса:$ipv4_address"
	echo "token: $token"
	echo
	echo "Информация о панели FRP"
	echo "Адрес панели FRP: http://$ipv4_address:$dashboard_port"
	echo "Имя пользователя панели FRP:$dashboard_user"
	echo "Пароль панели FRP:$dashboard_pwd"
	echo

	open_port 8055 8056

}



configure_frpc() {
	send_stats "Установить клиент frp"
	read -e -p "Пожалуйста, введите IP-адрес док-станции внешней сети:" server_addr
	read -e -p "Введите токен стыковки внешней сети:" token
	echo

	mkdir -p /home/frp
	touch /home/frp/frpc.toml
	cat <<EOF > /home/frp/frpc.toml
[common]
server_addr = ${server_addr}
server_port = 8055
token = ${token}

EOF

	donlond_frp frpc

	open_port 8055

}

add_forwarding_service() {
	send_stats "Добавить службу интрасети frp"
	# Запрашивает у пользователя имя службы и информацию о пересылке.
	read -e -p "Пожалуйста, введите название услуги:" service_name
	read -e -p "Пожалуйста, введите тип пересылки (tcp/udp) [Введите значение по умолчанию — TCP]:" service_type
	local service_type=${service_type:-tcp}
	read -e -p "Пожалуйста, введите IP-адрес интрасети [по умолчанию — 127.0.0.1 при нажатии Enter]:" local_ip
	local local_ip=${local_ip:-127.0.0.1}
	read -e -p "Пожалуйста, введите порт интрасети:" local_port
	read -e -p "Пожалуйста, введите порт внешней сети:" remote_port

	# Запись введенных пользователем данных в файл конфигурации
	cat <<EOF >> /home/frp/frpc.toml
[$service_name]
type = ${service_type}
local_ip = ${local_ip}
local_port = ${local_port}
remote_port = ${remote_port}

EOF

	# Вывод сгенерированной информации
	echo "Служить$service_nameУспешно добавлено в frpc.toml."

	docker restart frpc

	open_port $local_port

}



delete_forwarding_service() {
	send_stats "Удалить службу интрасети frp"
	# Предложить пользователю ввести название службы, которую необходимо удалить.
	read -e -p "Пожалуйста, введите название услуги, которую необходимо удалить:" service_name
	# Используйте sed для удаления службы и связанной с ней конфигурации.
	sed -i "/\[$service_name\]/,/^$/d" /home/frp/frpc.toml
	echo "Служить$service_nameУспешно удалено из frpc.toml."

	docker restart frpc

}


list_forwarding_services() {
	local config_file="$1"

	# Распечатать заголовок
	printf "%-20s %-25s %-30s %-10s\n" "Название службы" "Адрес интрасети" "Внешний сетевой адрес" "протокол"

	awk '
	BEGIN {
		server_addr=""
		server_port=""
		current_service=""
	}

	/^server_addr = / {
		gsub(/"|'"'"'/, "", $3)
		server_addr=$3
	}

	/^server_port = / {
		gsub(/"|'"'"'/, "", $3)
		server_port=$3
	}

	/^\[.*\]/ {
		# Если информация об услуге уже существует, распечатайте текущую услугу перед обработкой новой услуги.
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}

		# Обновить текущее имя службы
		if ($1 != "[common]") {
			gsub(/[\[\]]/, "", $1)
			current_service=$1
			# Очистить предыдущее значение
			local_ip=""
			local_port=""
			remote_port=""
			type=""
		}
	}

	/^local_ip = / {
		gsub(/"|'"'"'/, "", $3)
		local_ip=$3
	}

	/^local_port = / {
		gsub(/"|'"'"'/, "", $3)
		local_port=$3
	}

	/^remote_port = / {
		gsub(/"|'"'"'/, "", $3)
		remote_port=$3
	}

	/^type = / {
		gsub(/"|'"'"'/, "", $3)
		type=$3
	}

	END {
		# Распечатать информацию о последней услуге
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}
	}' "$config_file"
}



# Получить порт сервера FRP
get_frp_ports() {
	mapfile -t ports < <(ss -tulnape | grep frps | awk '{print $5}' | awk -F':' '{print $NF}' | sort -u)
}

# Создать адрес доступа
generate_access_urls() {
	# Сначала получите все порты
	get_frp_ports

	# Проверьте, есть ли порт, отличный от 8055/8056.
	local has_valid_ports=false
	for port in "${ports[@]}"; do
		if [[ $port != "8055" && $port != "8056" ]]; then
			has_valid_ports=true
			break
		fi
	done

	# Показывать заголовок и содержимое только при наличии действующего порта
	if [ "$has_valid_ports" = true ]; then
		echo "Адрес внешнего доступа к сервису FRP:"

		# Обработка IPv4-адресов
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				echo "http://${ipv4_address}:${port}"
			fi
		done

		# Обработка IPv6-адреса, если он присутствует.
		if [ -n "$ipv6_address" ]; then
			for port in "${ports[@]}"; do
				if [[ $port != "8055" && $port != "8056" ]]; then
					echo "http://[${ipv6_address}]:${port}"
				fi
			done
		fi

		# Обработка конфигурации HTTPS
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				local frps_search_pattern="${ipv4_address}:${port}"
				local frps_search_pattern2="127.0.0.1:${port}"
				for file in /home/web/conf.d/*.conf; do
					if [ -f "$file" ]; then
						if grep -q "$frps_search_pattern" "$file" 2>/dev/null || grep -q "$frps_search_pattern2" "$file" 2>/dev/null; then
							echo "https://$(basename "$file" .conf)"
						fi
					fi
				done
			fi
		done
	fi
}


frps_main_ports() {
	ip_address
	generate_access_urls
}




frps_panel() {
	send_stats "FRP-сервер"
	local app_id="55"
	local docker_name="frps"
	local docker_port=8056
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP-сервер$check_frp $update_status"
		echo "Создайте среду службы проникновения в интрасеть FRP и предоставьте доступ к Интернету устройствам без общедоступного IP-адреса."
		echo "Официальный сайт: введение:${gh_https_url}github.com/fatedier/frp/"
		echo "Видеоурок: https://www.bilibili.com/video/BV1yMw6e2EwL?t=124.0"
		if [ -d "/home/frp/" ]; then
			check_docker_app_ip
			frps_main_ports
		fi
		echo ""
		echo "------------------------"
		echo "1. Установить 2. Обновить 3. Удалить"
		echo "------------------------"
		echo "5. Доступ к доменному имени службы интрасети. 6. Удаление доступа к доменному имени."
		echo "------------------------"
		echo "7. Разрешить доступ по IP+порту. 8. Заблокировать доступ по IP+порту."
		echo "------------------------"
		echo "00. Обновить статус услуги 0. Возврат в предыдущее меню."
		echo "------------------------"
		read -e -p "Введите свой выбор:" choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				generate_frps_config

				add_app_id
				echo "Сервер FRP установлен."
				;;
			2)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frps.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frps.toml /home/frp/frps.toml
				donlond_frp frps

				add_app_id
				echo "Сервер FRP обновлен."
				;;
			3)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine
				rm -rf /home/frp

				close_port 8055 8056

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "Приложение удалено"
				;;
			5)
				echo "Служба обратного проникновения в интранет для доступа к доменным именам"
				send_stats "Доступ к внешнему доменному имени FRP"
				add_yuming
				read -e -p "Пожалуйста, введите порт службы проникновения в интранет:" frps_port
				ldnmp_Proxy ${yuming} 127.0.0.1 ${frps_port}
				block_host_port "$frps_port" "$ipv4_address"
				;;
			6)
				echo "Формат доменного имени example.com без https://"
				web_del
				;;

			7)
				send_stats "Разрешить доступ по IP"
				read -e -p "Пожалуйста, введите порт, который необходимо освободить:" frps_port
				clear_host_port_rules "$frps_port" "$ipv4_address"
				;;

			8)
				send_stats "Заблокировать доступ по IP"
				echo "Если у вас отменен доступ к доменному имени, вы можете использовать эту функцию, чтобы заблокировать доступ к порту IP+, что более безопасно."
				read -e -p "Пожалуйста, введите порт, который необходимо заблокировать:" frps_port
				block_host_port "$frps_port" "$ipv4_address"
				;;

			00)
				send_stats "Обновить статус услуги FRP"
				echo "Статус услуги FRP обновлен."
				;;

			*)
				break
				;;
		esac
		break_end
	done
}


frpc_panel() {
	send_stats "FRP-клиент"
	local app_id="56"
	local docker_name="frpc"
	local docker_port=8055
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP-клиент$check_frp $update_status"
		echo "Подключитесь к серверу. После подключения вы можете создать службу проникновения в интранет для доступа в Интернет."
		echo "Официальный сайт: введение:${gh_https_url}github.com/fatedier/frp/"
		echo "Видеоурок: https://www.bilibili.com/video/BV1yMw6e2EwL?t=173.9"
		echo "------------------------"
		if [ -d "/home/frp/" ]; then
			[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
			list_forwarding_services "/home/frp/frpc.toml"
		fi
		echo ""
		echo "------------------------"
		echo "1. Установить 2. Обновить 3. Удалить"
		echo "------------------------"
		echo "4. Добавить внешние службы 5. Удалить внешние службы 6. Настроить службы вручную"
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Введите свой выбор:" choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				configure_frpc

				add_app_id
				echo "Клиент FRP установлен."
				;;
			2)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
				donlond_frp frpc

				add_app_id
				echo "Клиент FRP обновлен."
				;;

			3)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine
				rm -rf /home/frp
				close_port 8055

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "Приложение удалено"
				;;

			4)
				add_forwarding_service
				;;

			5)
				delete_forwarding_service
				;;

			6)
				install nano
				nano /home/frp/frpc.toml
				docker restart frpc
				;;

			*)
				break
				;;
		esac
		break_end
	done
}




yt_menu_pro() {

	local app_id="66"
	local VIDEO_DIR="/home/yt-dlp"
	local URL_FILE="$VIDEO_DIR/urls.txt"
	local ARCHIVE_FILE="$VIDEO_DIR/archive.txt"

	mkdir -p "$VIDEO_DIR"

	while true; do

		if [ -x "/usr/local/bin/yt-dlp" ]; then
		   local YTDLP_STATUS="${gl_lv}Установлено${gl_bai}"
		else
		   local YTDLP_STATUS="${gl_hui}Не установлено${gl_bai}"
		fi

		clear
		send_stats "инструмент загрузки yt-dlp"
		echo -e "yt-dlp $YTDLP_STATUS"
		echo -e "yt-dlp — это мощный инструмент для загрузки видео, который поддерживает тысячи сайтов, таких как YouTube, Bilibili, Twitter и т. д."
		echo -e "Официальный адрес сайта:${gh_https_url}github.com/yt-dlp/yt-dlp"
		echo "-------------------------"
		echo "Список скачанных видео:"
		ls -td "$VIDEO_DIR"/*/ 2>/dev/null || echo "(Пока нет)"
		echo "-------------------------"
		echo "1. Установить 2. Обновить 3. Удалить"
		echo "-------------------------"
		echo "5. Загрузка отдельного видео 6. Пакетная загрузка видео 7. Загрузка пользовательских параметров"
		echo "8. Загрузить как аудио в формате MP3. 9. Удалить каталог видео. 10. Управление файлами cookie (в разработке)."
		echo "-------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "-------------------------"
		read -e -p "Пожалуйста, введите номер опции:" choice

		case $choice in
			1)
				send_stats "Установка yt-dlp..."
				echo "Установка yt-dlp..."
				install ffmpeg
				curl -L ${gh_https_url}github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
				chmod a+rx /usr/local/bin/yt-dlp

				add_app_id
				echo "Установка завершена. Нажмите любую клавишу, чтобы продолжить..."
				read ;;
			2)
				send_stats "Обновление yt-dlp..."
				echo "Обновление yt-dlp..."
				yt-dlp -U

				add_app_id
				echo "Обновление завершено. Нажмите любую клавишу, чтобы продолжить..."
				read ;;
			3)
				send_stats "Удаление yt-dlp..."
				echo "Удаление yt-dlp..."
				rm -f /usr/local/bin/yt-dlp

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "Удаление завершено. Нажмите любую клавишу, чтобы продолжить..."
				read ;;
			5)
				send_stats "Загрузка одного видео"
				read -e -p "Пожалуйста, введите ссылку на видео:" url
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "Загрузка завершена. Нажмите любую клавишу, чтобы продолжить..." ;;
			6)
				send_stats "Пакетная загрузка видео"
				install nano
				if [ ! -f "$URL_FILE" ]; then
				  echo -e "# Введите несколько адресов ссылок на видео\n# https://www.bilibili.com/bangumi/play/ep733316?spm_id_from=333.337.0.0&from_spmid=666.25.episode.0" > "$URL_FILE"
				fi
				nano $URL_FILE
				echo "Начать пакетную загрузку сейчас..."
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-a "$URL_FILE" \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "Пакетная загрузка завершена. Нажмите любую клавишу, чтобы продолжить..." ;;
			7)
				send_stats "Пользовательская загрузка видео"
				read -e -p "Введите полные параметры yt-dlp (за исключением yt-dlp):" custom
				yt-dlp -P "$VIDEO_DIR" $custom \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "Выполнение завершено, нажмите любую клавишу, чтобы продолжить..." ;;
			8)
				send_stats "скачать MP3"
				read -e -p "Пожалуйста, введите ссылку на видео:" url
				yt-dlp -P "$VIDEO_DIR" -x --audio-format mp3 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "Загрузка аудио завершена. Нажмите любую клавишу, чтобы продолжить..." ;;

			9)
				send_stats "Удалить видео"
				read -e -p "Пожалуйста, введите название удаленного видео:" rmdir
				rm -rf "$VIDEO_DIR/$rmdir"
				;;
			*)
				break ;;
		esac
	done
}





current_timezone() {
	if grep -q 'Alpine' /etc/issue; then
	   date +"%Z %z"
	else
	   timedatectl | grep "Time zone" | awk '{print $3}'
	fi

}


set_timedate() {
	local shiqu="$1"
	if grep -q 'Alpine' /etc/issue; then
		install tzdata
		cp /usr/share/zoneinfo/${shiqu} /etc/localtime
		hwclock --systohc
	else
		timedatectl set-timezone ${shiqu}
	fi
}



# Исправить проблему с прерыванием dpkg
fix_dpkg() {
	pkill -9 -f 'apt|dpkg'
	rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock
	DEBIAN_FRONTEND=noninteractive dpkg --configure -a
}


linux_update() {
	echo -e "${gl_kjlan}Выполняется обновление системы...${gl_bai}"
	if command -v dnf &>/dev/null; then
		dnf -y update
	elif command -v yum &>/dev/null; then
		yum -y update
	elif command -v apt &>/dev/null; then
		fix_dpkg
		DEBIAN_FRONTEND=noninteractive apt update -y
		DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
	elif command -v apk &>/dev/null; then
		apk update && apk upgrade
	elif command -v pacman &>/dev/null; then
		pacman -Syu --noconfirm
	elif command -v zypper &>/dev/null; then
		zypper refresh
		zypper update
	elif command -v opkg &>/dev/null; then
		opkg update
	else
		echo "Неизвестный менеджер пакетов!"
		return
	fi
}



linux_clean() {
	echo -e "${gl_kjlan}Идет очистка системы...${gl_bai}"
	if command -v dnf &>/dev/null; then
		rpm --rebuilddb
		dnf autoremove -y
		dnf clean all
		dnf makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v yum &>/dev/null; then
		rpm --rebuilddb
		yum autoremove -y
		yum clean all
		yum makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apt &>/dev/null; then
		fix_dpkg
		apt autoremove --purge -y
		apt clean -y
		apt autoclean -y
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apk &>/dev/null; then
		echo "Очистить кеш менеджера пакетов..."
		apk cache clean
		echo "Удалить системный журнал..."
		rm -rf /var/log/*
		echo "Удалить кэш APK..."
		rm -rf /var/cache/apk/*
		echo "Удалить временные файлы..."
		rm -rf /tmp/*

	elif command -v pacman &>/dev/null; then
		pacman -Rns $(pacman -Qdtq) --noconfirm
		pacman -Scc --noconfirm
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v zypper &>/dev/null; then
		zypper clean --all
		zypper refresh
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v opkg &>/dev/null; then
		echo "Удалить системный журнал..."
		rm -rf /var/log/*
		echo "Удалить временные файлы..."
		rm -rf /tmp/*

	elif command -v pkg &>/dev/null; then
		echo "Очистите неиспользуемые зависимости..."
		pkg autoremove -y
		echo "Очистить кеш менеджера пакетов..."
		pkg clean -y
		echo "Удалить системный журнал..."
		rm -rf /var/log/*
		echo "Удалить временные файлы..."
		rm -rf /tmp/*

	else
		echo "Неизвестный менеджер пакетов!"
		return
	fi
	return
}



bbr_on() {

sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

}


set_dns() {

ip_address

chattr -i /etc/resolv.conf
> /etc/resolv.conf

if [ -n "$ipv4_address" ]; then
	echo "nameserver $dns1_ipv4" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv4" >> /etc/resolv.conf
fi

if [ -n "$ipv6_address" ]; then
	echo "nameserver $dns1_ipv6" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv6" >> /etc/resolv.conf
fi

if [ ! -s /etc/resolv.conf ]; then
	echo "nameserver 223.5.5.5" >> /etc/resolv.conf
	echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

chattr +i /etc/resolv.conf

}


set_dns_ui() {
root_use
send_stats "Оптимизировать DNS"
while true; do
	clear
	echo "Оптимизировать DNS-адрес"
	echo "------------------------"
	echo "Текущий DNS-адрес"
	cat /etc/resolv.conf
	echo "------------------------"
	echo ""
	echo "1. Оптимизация зарубежного DNS:"
	echo " v4: 1.1.1.1 8.8.8.8"
	echo " v6: 2606:4700:4700::1111 2001:4860:4860::8888"
	echo "2. Внутренняя оптимизация DNS:"
	echo " v4: 223.5.5.5 183.60.83.19"
	echo " v6: 2400:3200::1 2400:da00::6666"
	echo "3. Отредактируйте конфигурацию DNS вручную."
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" Limiting
	case "$Limiting" in
	  1)
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
		set_dns
		send_stats "Оптимизация зарубежного DNS"
		;;
	  2)
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
		set_dns
		send_stats "Внутренняя оптимизация DNS"
		;;
	  3)
		install nano
		chattr -i /etc/resolv.conf
		nano /etc/resolv.conf
		chattr +i /etc/resolv.conf
		send_stats "Редактировать конфигурацию DNS вручную"
		;;
	  *)
		break
		;;
	esac
done

}



restart_ssh() {
	restart sshd ssh > /dev/null 2>&1

}



correct_ssh_config() {

	local sshd_config="/etc/ssh/sshd_config"


	if grep -Eq "^\s*PasswordAuthentication\s+no" "$sshd_config"; then
		sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
			   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
			   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
			   -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$sshd_config"
	else
		sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin yes/' \
			   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication yes/' \
			   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' "$sshd_config"
	fi

	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
}


new_ssh_port() {

  local new_port=$1

  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  sed -i '/^\s*#\?\s*Port\s\+/d' /etc/ssh/sshd_config
  echo "Port $new_port" >> /etc/ssh/sshd_config

  correct_ssh_config

  restart_ssh
  open_port $new_port
  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1

  echo "Порт SSH был изменен следующим образом:$new_port"

  sleep 1

}



sshkey_on() {

	sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
		   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
		   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
		   -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
	restart_ssh
	echo -e "${gl_lv}Режим входа с использованием ключа пользователя включен, а режим входа с паролем выключен. Повторное подключение вступит в силу.${gl_bai}"

}



add_sshkey() {
	chmod 700 "${HOME}"
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"
	touch "${HOME}/.ssh/authorized_keys"

	ssh-keygen -t ed25519 -C "xxxx@gmail.com" -f "${HOME}/.ssh/sshkey" -N ""

	cat "${HOME}/.ssh/sshkey.pub" >> "${HOME}/.ssh/authorized_keys"
	chmod 600 "${HOME}/.ssh/authorized_keys"

	ip_address
	echo -e "Информация о закрытом ключе была сгенерирована. Обязательно скопируйте и сохраните его. Его можно сохранить как${gl_huang}${ipv4_address}_ssh.key${gl_bai}файл для будущих входов в систему SSH"

	echo "--------------------------------"
	cat "${HOME}/.ssh/sshkey"
	echo "--------------------------------"

	sshkey_on
}





import_sshkey() {

	local public_key="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local auth_keys="${ssh_dir}/authorized_keys"

	if [[ -z "$public_key" ]]; then
		read -e -p "Введите содержимое вашего открытого ключа SSH (обычно начинается с «ssh-rsa» или «ssh-ed25519»):" public_key
	fi

	if [[ -z "$public_key" ]]; then
		echo -e "${gl_hong}Ошибка: содержимое открытого ключа не введено.${gl_bai}"
		return 1
	fi

	if [[ ! "$public_key" =~ ^ssh-(rsa|ed25519|ecdsa) ]]; then
		echo -e "${gl_hong}Ошибка: Не похоже на законный открытый ключ SSH.${gl_bai}"
		return 1
	fi

	if grep -Fxq "$public_key" "$auth_keys" 2>/dev/null; then
		echo "Открытый ключ уже существует, не нужно добавлять его еще раз."
		return 0
	fi

	mkdir -p "$ssh_dir"
	chmod 700 "$ssh_dir"
	touch "$auth_keys"
	echo "$public_key" >> "$auth_keys"
	chmod 600 "$auth_keys"

	sshkey_on
}



fetch_remote_ssh_keys() {

	local keys_url="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local authorized_keys="${ssh_dir}/authorized_keys"
	local temp_file

	if [[ -z "${keys_url}" ]]; then
		read -e -p "Введите URL-адрес удаленного открытого ключа:" keys_url
	fi

	echo "Этот скрипт извлечет открытый ключ SSH с удаленного URL-адреса и добавит его в${authorized_keys}"
	echo ""
	echo "Адрес удаленного открытого ключа:"
	echo "  ${keys_url}"
	echo ""

	# Создание временных файлов
	temp_file=$(mktemp)

	# Скачать открытый ключ
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --connect-timeout 10 "${keys_url}" -o "${temp_file}" || {
			echo "Ошибка: невозможно загрузить открытый ключ по URL-адресу (проблема с сетью или неверный адрес)." >&2
			rm -f "${temp_file}"
			return 1
		}
	elif command -v wget >/dev/null 2>&1; then
		wget -q --timeout=10 -O "${temp_file}" "${keys_url}" || {
			echo "Ошибка: невозможно загрузить открытый ключ по URL-адресу (проблема с сетью или неверный адрес)." >&2
			rm -f "${temp_file}"
			return 1
		}
	else
		echo "Ошибка: Curl или wget не найдены в системе, невозможно загрузить открытый ключ." >&2
		rm -f "${temp_file}"
		return 1
	fi

	# Проверьте, действителен ли контент
	if [[ ! -s "${temp_file}" ]]; then
		echo "Ошибка: загруженный файл пуст, и URL-адрес не может содержать открытый ключ." >&2
		rm -f "${temp_file}"
		return 1
	fi

	mkdir -p "${ssh_dir}"
	chmod 700 "${ssh_dir}"
	touch "${authorized_keys}"
	chmod 600 "${authorized_keys}"

	# Резервное копирование исходных авторизованных_ключей
	if [[ -f "${authorized_keys}" ]]; then
		cp "${authorized_keys}" "${authorized_keys}.bak.$(date +%Y%m%d-%H%M%S)"
		echo "Исходный файлauthorized_keys зарезервирован."
	fi

	# Добавить открытый ключ (избегать дублирования)
	local added=0
	while IFS= read -r line; do
		[[ -z "${line}" || "${line}" =~ ^# ]] && continue

		if ! grep -Fxq "${line}" "${authorized_keys}" 2>/dev/null; then
			echo "${line}" >> "${authorized_keys}"
			((added++))
		fi
	done < "${temp_file}"

	rm -f "${temp_file}"

	echo ""
	if (( added > 0 )); then
		echo "успешно добавлено${added}Поступил новый открытый ключ${authorized_keys}"
		sshkey_on
	else
		echo "Не требуется добавлять новые открытые ключи (все они могут уже существовать)"
	fi

	echo ""
}




fetch_github_ssh_keys() {

	local username="$1"
	local base_dir="${2:-$HOME}"

	echo "Прежде чем продолжить, убедитесь, что вы добавили открытый ключ SSH в свою учетную запись GitHub:"
	echo "1. Войдите в систему${gh_https_url}github.com/settings/keys"
	echo "2. Нажмите «Новый ключ SSH» или «Добавить ключ SSH»."
	echo "3. Название можно заполнить по желанию (например: Домашний Ноутбук 2026)"
	echo "4. Вставьте содержимое локального открытого ключа (обычно все содержимое ~/.ssh/id_ed25519.pub или id_rsa.pub) в поле «Ключ»."
	echo "5. Нажмите Добавить ключ SSH, чтобы завершить добавление."
	echo ""
	echo "После добавления все ваши открытые ключи будут общедоступны на GitHub по адресу:"
	echo "  ${gh_https_url}github.com/вашеимя_пользователя.keys"
	echo ""


	if [[ -z "${username}" ]]; then
		read -e -p "Пожалуйста, введите свое имя пользователя GitHub (имя пользователя без @):" username
	fi

	if [[ -z "${username}" ]]; then
		echo "Ошибка: имя пользователя GitHub не может быть пустым." >&2
		return 1
	fi

	keys_url="${gh_https_url}github.com/${username}.keys"

	fetch_remote_ssh_keys "${keys_url}" "${base_dir}"

}


sshkey_panel() {
  root_use
  send_stats "Вход с ключом пользователя"
  while true; do
	  clear
	  local REAL_STATUS=$(grep -i "^PubkeyAuthentication" /etc/ssh/sshd_config | tr '[:upper:]' '[:lower:]')
	  if [[ "$REAL_STATUS" =~ "yes" ]]; then
		  IS_KEY_ENABLED="${gl_lv}Включено${gl_bai}"
	  else
	  	  IS_KEY_ENABLED="${gl_hui}Не включено${gl_bai}"
	  fi
  	  echo -e "Режим входа в систему с помощью ключа пользователя${IS_KEY_ENABLED}"
  	  echo "Расширенный игровой процесс: https://blog.kejilion.pro/ssh-key"
  	  echo "------------------------------------------------"
  	  echo "Будет сгенерирована пара ключей, более безопасный способ входа в систему через SSH."
	  echo "------------------------"
	  echo "1. Создайте новую пару ключей. 2. Введите существующий открытый ключ вручную."
	  echo "3. Импортируйте существующий открытый ключ из GitHub. 4. Импортируйте существующий открытый ключ из URL-адреса."
	  echo "5. Отредактируйте файл открытого ключа. 6. Просмотрите локальный ключ."
	  echo "------------------------"
	  echo "0. Вернуться в предыдущее меню"
	  echo "------------------------"
	  read -e -p "Пожалуйста, введите ваш выбор:" host_dns
	  case $host_dns in
		  1)
	  		send_stats "Создать новый ключ"
	  		add_sshkey
			break_end
			  ;;
		  2)
			send_stats "Импортировать существующий открытый ключ"
			import_sshkey
			break_end
			  ;;
		  3)
			send_stats "Импортировать удаленный открытый ключ GitHub"
			fetch_github_ssh_keys
			break_end
			  ;;
		  4)
			send_stats "Импортировать удаленный открытый ключ URL-адреса"
			read -e -p "Введите URL-адрес удаленного открытого ключа:" keys_url
			fetch_remote_ssh_keys "${keys_url}"
			break_end
			  ;;

		  5)
			send_stats "Редактировать файл открытого ключа"
			install nano
			nano ${HOME}/.ssh/authorized_keys
			break_end
			  ;;

		  6)
			send_stats "Посмотреть локальный ключ"
			echo "------------------------"
			echo "Информация об открытом ключе"
			cat ${HOME}/.ssh/authorized_keys
			echo "------------------------"
			echo "Информация о закрытом ключе"
			cat ${HOME}/.ssh/sshkey
			echo "------------------------"
			break_end
			  ;;
		  *)
			  break  # 跳出循环，退出菜单
			  ;;
	  esac
  done


}






add_sshpasswd() {

	root_use
	send_stats "Установить режим входа с паролем"
	echo "Установить режим входа с паролем"

	local target_user="$1"

	# Если параметры не переданы, введите интерактивно
	if [[ -z "$target_user" ]]; then
		read -e -p "Введите имя пользователя, пароль которого вы хотите изменить (по умолчанию root):" target_user
	fi

	# Нажмите Enter и не вводите, по умолчанию root
	target_user=${target_user:-root}

	# Убедитесь, что пользователь существует
	if ! id "$target_user" >/dev/null 2>&1; then
		echo "Ошибка: пользователь$target_userне существует"
		return 1
	fi

	passwd "$target_user"

	if [[ "$target_user" == "root" ]]; then
		sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
	fi

	sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*

	restart_ssh

	echo -e "${gl_lv}Пароль установлен и изменен на режим входа по паролю!${gl_bai}"
}














root_use() {
clear
[ "$EUID" -ne 0 ] && echo -e "${gl_huang}намекать:${gl_bai}Для запуска этой функции требуется пользователь root!" && break_end && kejilion
}












dd_xitong() {
		send_stats "Переустановите систему"
		dd_xitong_MollyLau() {
			wget --no-check-certificate -qO InstallNET.sh "${gh_proxy}raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh" && chmod a+x InstallNET.sh

		}

		dd_xitong_bin456789() {
			curl -O ${gh_proxy}raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
		}

		dd_xitong_1() {
		  echo -e "Первоначальное имя пользователя после переустановки:${gl_huang}root${gl_bai}Начальный пароль:${gl_huang}LeitboGi0ro${gl_bai}Начальный порт:${gl_huang}22${gl_bai}"
		  echo -e "${gl_huang}После переустановки своевременно измените первоначальный пароль, чтобы предотвратить насильственное вторжение. Введите passwd в командной строке, чтобы изменить пароль.${gl_bai}"
		  echo -e "Нажмите любую клавишу, чтобы продолжить..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_2() {
		  echo -e "Первоначальное имя пользователя после переустановки:${gl_huang}Administrator${gl_bai}Начальный пароль:${gl_huang}Teddysun.com${gl_bai}Начальный порт:${gl_huang}3389${gl_bai}"
		  echo -e "Нажмите любую клавишу, чтобы продолжить..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_3() {
		  echo -e "Первоначальное имя пользователя после переустановки:${gl_huang}root${gl_bai}Начальный пароль:${gl_huang}123@@@${gl_bai}Начальный порт:${gl_huang}22${gl_bai}"
		  echo -e "Нажмите любую клавишу, чтобы продолжить..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		dd_xitong_4() {
		  echo -e "Первоначальное имя пользователя после переустановки:${gl_huang}Administrator${gl_bai}Начальный пароль:${gl_huang}123@@@${gl_bai}Начальный порт:${gl_huang}3389${gl_bai}"
		  echo -e "Нажмите любую клавишу, чтобы продолжить..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		  while true; do
			root_use
			echo "Переустановите систему"
			echo "--------------------------------"
			echo -e "${gl_hong}Уведомление:${gl_bai}Переустановка может привести к потере соединения, поэтому будьте осторожны, если вы обеспокоены. Ожидается, что переустановка займет 15 минут. Пожалуйста, заранее сделайте резервную копию данных."
			echo -e "${gl_hui}Спасибо боссу bin456789 и боссу leitbogioro за поддержку сценариев!${gl_bai} "
			echo -e "${gl_hui}bin456789 адрес проекта:${gh_https_url}github.com/bin456789/reinstall${gl_bai}"
			echo -e "${gl_hui}Адрес проекта leitbogioro:${gh_https_url}github.com/leitbogioro/Tools${gl_bai}"
			echo "------------------------"
			echo "1. Debian 13                  2. Debian 12"
			echo "3. Debian 11                  4. Debian 10"
			echo "------------------------"
			echo "11. Ubuntu 24.04              12. Ubuntu 22.04"
			echo "13. Ubuntu 20.04              14. Ubuntu 18.04"
			echo "------------------------"
			echo "21. Rocky Linux 10            22. Rocky Linux 9"
			echo "23. Alma Linux 10             24. Alma Linux 9"
			echo "25. oracle Linux 10           26. oracle Linux 9"
			echo "27. Fedora Linux 42           28. Fedora Linux 41"
			echo "29. CentOS 10                 30. CentOS 9"
			echo "------------------------"
			echo "31. Alpine Linux              32. Arch Linux"
			echo "33. Kali Linux                34. openEuler"
			echo "35. openSUSE Tumbleweed 36. Публичная бета-версия fnos Feiniu"
			echo "------------------------"
			echo "41. Windows 11                42. Windows 10"
			echo "43. Windows 7                 44. Windows Server 2025"
			echo "45. Windows Server 2022       46. Windows Server 2019"
			echo "47. Windows 11 ARM"
			echo "------------------------"
			echo "0. Вернуться в предыдущее меню"
			echo "------------------------"
			read -e -p "Пожалуйста, выберите систему, которую вы хотите переустановить:" sys_choice
			case "$sys_choice" in


			  1)
				send_stats "Переустановите Дебиан 13."
				dd_xitong_3
				bash reinstall.sh debian 13
				reboot
				exit
				;;

			  2)
				send_stats "Переустановите дебиан 12."
				dd_xitong_1
				bash InstallNET.sh -debian 12
				reboot
				exit
				;;
			  3)
				send_stats "Переустановите Дебиан 11."
				dd_xitong_1
				bash InstallNET.sh -debian 11
				reboot
				exit
				;;
			  4)
				send_stats "Переустановите дебиан 10"
				dd_xitong_1
				bash InstallNET.sh -debian 10
				reboot
				exit
				;;
			  11)
				send_stats "Переустановите Убунту 24.04."
				dd_xitong_1
				bash InstallNET.sh -ubuntu 24.04
				reboot
				exit
				;;
			  12)
				send_stats "Переустановите Убунту 22.04."
				dd_xitong_1
				bash InstallNET.sh -ubuntu 22.04
				reboot
				exit
				;;
			  13)
				send_stats "Переустановите Убунту 20.04."
				dd_xitong_1
				bash InstallNET.sh -ubuntu 20.04
				reboot
				exit
				;;
			  14)
				send_stats "Переустановите Убунту 18.04."
				dd_xitong_1
				bash InstallNET.sh -ubuntu 18.04
				reboot
				exit
				;;


			  21)
				send_stats "Переустановите Rockylinux10"
				dd_xitong_3
				bash reinstall.sh rocky
				reboot
				exit
				;;

			  22)
				send_stats "Переустановите Rockylinux9"
				dd_xitong_3
				bash reinstall.sh rocky 9
				reboot
				exit
				;;

			  23)
				send_stats "Переустановите альма10"
				dd_xitong_3
				bash reinstall.sh almalinux
				reboot
				exit
				;;

			  24)
				send_stats "Переустановите альма9"
				dd_xitong_3
				bash reinstall.sh almalinux 9
				reboot
				exit
				;;

			  25)
				send_stats "Переустановите оракул10"
				dd_xitong_3
				bash reinstall.sh oracle
				reboot
				exit
				;;

			  26)
				send_stats "Переустановите оракул9"
				dd_xitong_3
				bash reinstall.sh oracle 9
				reboot
				exit
				;;

			  27)
				send_stats "Переустановите Fedora42."
				dd_xitong_3
				bash reinstall.sh fedora
				reboot
				exit
				;;

			  28)
				send_stats "Переустановите Fedora41"
				dd_xitong_3
				bash reinstall.sh fedora 41
				reboot
				exit
				;;

			  29)
				send_stats "Переустановите centos10"
				dd_xitong_3
				bash reinstall.sh centos 10
				reboot
				exit
				;;

			  30)
				send_stats "Переустановите Centos9"
				dd_xitong_3
				bash reinstall.sh centos 9
				reboot
				exit
				;;

			  31)
				send_stats "Переустановите альпийский"
				dd_xitong_1
				bash InstallNET.sh -alpine
				reboot
				exit
				;;

			  32)
				send_stats "Переустановить арку"
				dd_xitong_3
				bash reinstall.sh arch
				reboot
				exit
				;;

			  33)
				send_stats "Переустановите Кали"
				dd_xitong_3
				bash reinstall.sh kali
				reboot
				exit
				;;

			  34)
				send_stats "Переустановить опенейлер"
				dd_xitong_3
				bash reinstall.sh openeuler
				reboot
				exit
				;;

			  35)
				send_stats "Переустановите opensuse"
				dd_xitong_3
				bash reinstall.sh opensuse
				reboot
				exit
				;;

			  36)
				send_stats "Переустановите Фейниу"
				dd_xitong_3
				bash reinstall.sh fnos
				reboot
				exit
				;;

			  41)
				send_stats "Переустановить виндовс 11"
				dd_xitong_2
				bash InstallNET.sh -windows 11 -lang "cn"
				reboot
				exit
				;;

			  42)
				dd_xitong_2
				send_stats "Переустановите Windows 10"
				bash InstallNET.sh -windows 10 -lang "cn"
				reboot
				exit
				;;

			  43)
				send_stats "Переустановить виндовс7"
				dd_xitong_4
				bash reinstall.sh windows --iso="https://drive.massgrave.dev/cn_windows_7_professional_with_sp1_x64_dvd_u_677031.iso" --image-name='Windows 7 PROFESSIONAL'
				reboot
				exit
				;;

			  44)
				send_stats "Переустановите сервер Windows 25."
				dd_xitong_2
				bash InstallNET.sh -windows 2025 -lang "cn"
				reboot
				exit
				;;

			  45)
				send_stats "Переустановить сервер Windows 22."
				dd_xitong_2
				bash InstallNET.sh -windows 2022 -lang "cn"
				reboot
				exit
				;;

			  46)
				send_stats "Переустановите сервер Windows 19."
				dd_xitong_2
				bash InstallNET.sh -windows 2019 -lang "cn"
				reboot
				exit
				;;

			  47)
				send_stats "Переустановите Windows 11 ARM."
				dd_xitong_4
				bash reinstall.sh dd --img https://r2.hotdog.eu.org/win11-arm-with-pagefile-15g.xz
				reboot
				exit
				;;

			  *)
				break
				;;
			esac
		  done
}


bbrv3() {
		  root_use
		  send_stats "управление bbrv3"

		  local cpu_arch=$(uname -m)
		  if [ "$cpu_arch" = "aarch64" ]; then
			bash <(curl -sL jhb.ovh/jb/bbrv3arm.sh)
			break_end
			linux_Settings
		  fi

		  if dpkg -l | grep -q 'linux-xanmod'; then
			while true; do
				  clear
				  local kernel_version=$(uname -r)
				  echo "У вас установлено ядро ​​xanmod BBRv3."
				  echo "Текущая версия ядра:$kernel_version"

				  echo ""
				  echo "Управление ядром"
				  echo "------------------------"
				  echo "1. Обновите ядро ​​BBRv3. 2. Удалите ядро ​​BBRv3."
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
						apt purge -y 'linux-*xanmod1*'
						update-grub

						# wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
						wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

						# Шаг 3. Добавьте репозиторий
						echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

						# version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
						local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

						apt update -y
						apt install -y linux-xanmod-x64v$version

						echo "Ядро XanMod обновлено. Вступит в силу после перезапуска"
						rm -f /etc/apt/sources.list.d/xanmod-release.list
						rm -f check_x86-64_psabi.sh*

						server_reboot

						  ;;
					  2)
						apt purge -y 'linux-*xanmod1*'
						update-grub
						echo "Ядро XanMod было удалено. Вступит в силу после перезапуска"
						server_reboot
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;

				  esac
			done
		else

		  clear
		  echo "Настройте ускорение BBR3"
		  echo "Видео-знакомство: https://www.bilibili.com/video/BV14K421x7BS?t=0.1"
		  echo "------------------------------------------------"
		  echo "Поддерживает только Debian/Ubuntu."
		  echo "Пожалуйста, сделайте резервную копию ваших данных, и мы обновим ваше ядро ​​Linux и включим BBR3."
		  echo "------------------------------------------------"
		  read -e -p "Вы уверены, что хотите продолжить? (Да/Нет):" choice

		  case "$choice" in
			[Yy])
			check_disk_space 3
			if [ -r /etc/os-release ]; then
				. /etc/os-release
				if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
					echo "Текущая среда не поддерживает это. Поддерживаются только системы Debian и Ubuntu."
					break_end
					linux_Settings
				fi
			else
				echo "Невозможно определить тип операционной системы"
				break_end
				linux_Settings
			fi

			check_swap
			install wget gnupg

			# wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
			wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

			# Шаг 3. Добавьте репозиторий
			echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

			# version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
			local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

			apt update -y
			apt install -y linux-xanmod-x64v$version

			bbr_on

			echo "Ядро XanMod установлено, и BBR3 успешно включен. Вступит в силу после перезапуска"
			rm -f /etc/apt/sources.list.d/xanmod-release.list
			rm -f check_x86-64_psabi.sh*
			server_reboot

			  ;;
			[Nn])
			  echo "Отменено"
			  ;;
			*)
			  echo "Неверный выбор, введите Y или N."
			  ;;
		  esac
		fi

}


elrepo_install() {
	# Импортируйте открытый ключ ELRepo GPG.
	echo "Импортируйте открытый ключ ELRepo GPG..."
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	# Проверьте версию системы
	local os_version=$(rpm -q --qf "%{VERSION}" $(rpm -qf /etc/os-release) 2>/dev/null | awk -F '.' '{print $1}')
	local os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	# Убедитесь, что мы работаем в поддерживаемой операционной системе.
	if [[ "$os_name" != *"Red Hat"* && "$os_name" != *"AlmaLinux"* && "$os_name" != *"Rocky"* && "$os_name" != *"Oracle"* && "$os_name" != *"CentOS"* ]]; then
		echo "Неподдерживаемые операционные системы:$os_name"
		break_end
		linux_Settings
	fi
	# Распечатать информацию об обнаруженной операционной системе
	echo "Обнаруженные операционные системы:$os_name $os_version"
	# Установите соответствующую конфигурацию хранилища ELRepo в соответствии с версией системы.
	if [[ "$os_version" == 8 ]]; then
		echo "Установка конфигурации репозитория ELRepo (версия 8)..."
		yum -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
	elif [[ "$os_version" == 9 ]]; then
		echo "Установка конфигурации репозитория ELRepo (версия 9)..."
		yum -y install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
	elif [[ "$os_version" == 10 ]]; then
		echo "Установка конфигурации репозитория ELRepo (версия 10)..."
		yum -y install https://www.elrepo.org/elrepo-release-10.el10.elrepo.noarch.rpm
	else
		echo "Неподдерживаемые версии системы:$os_version"
		break_end
		linux_Settings
	fi
	# Включите репозиторий ядра ELRepo и установите последнюю версию основного ядра.
	echo "Включите репозиторий ядра ELRepo и установите последнюю версию основного ядра..."
	# yum -y --enablerepo=elrepo-kernel install kernel-ml
	yum --nogpgcheck -y --enablerepo=elrepo-kernel install kernel-ml
	echo "Установлена ​​конфигурация репозитория ELRepo и обновлена ​​до последней версии основного ядра."
	server_reboot

}


elrepo() {
		  root_use
		  send_stats "Управление ядром Red Hat"
		  if uname -r | grep -q 'elrepo'; then
			while true; do
				  clear
				  kernel_version=$(uname -r)
				  echo "Вы установили ядро ​​elrepo"
				  echo "Текущая версия ядра:$kernel_version"

				  echo ""
				  echo "Управление ядром"
				  echo "------------------------"
				  echo "1. Обновите ядро ​​elrepo 2. Удалите ядро ​​elrepo"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						elrepo_install
						send_stats "Обновление ядра Red Hat"
						server_reboot

						  ;;
					  2)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						echo "Ядро elrepo было удалено. Вступит в силу после перезапуска"
						send_stats "Удалить ядро ​​Red Hat"
						server_reboot

						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;

				  esac
			done
		else

		  clear
		  echo "Пожалуйста, сделайте резервную копию ваших данных, и мы обновим ядро ​​Linux для вас."
		  echo "Видео-знакомство: https://www.bilibili.com/video/BV1mH4y1w7qA?t=529.2"
		  echo "------------------------------------------------"
		  echo "Поддерживается только дистрибутивы серии Red Hat CentOS/RedHat/Alma/Rocky/oracle."
		  echo "Обновление ядра Linux может улучшить производительность и безопасность системы. Рекомендуется попробовать, если это возможно, и с осторожностью обновлять производственную среду!"
		  echo "------------------------------------------------"
		  read -e -p "Вы уверены, что хотите продолжить? (Да/Нет):" choice

		  case "$choice" in
			[Yy])
			  check_swap
			  elrepo_install
			  send_stats "Обновите ядро ​​Red Hat."
			  server_reboot
			  ;;
			[Nn])
			  echo "Отменено"
			  ;;
			*)
			  echo "Неверный выбор, введите Y или N."
			  ;;
		  esac
		fi

}




clamav_freshclam() {
	echo -e "${gl_kjlan}Обновление вирусной базы...${gl_bai}"
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		clamav/clamav-debian:latest \
		freshclam
}

clamav_scan() {
	if [ $# -eq 0 ]; then
		echo "Укажите каталоги для сканирования."
		return
	fi

	echo -e "${gl_kjlan}Сканирование каталога $@...${gl_bai}"

	# Параметры монтирования сборки
	local MOUNT_PARAMS=""
	for dir in "$@"; do
		MOUNT_PARAMS+="--mount type=bind,source=${dir},target=/mnt/host${dir} "
	done

	# Создание параметров команды clamscan
	local SCAN_PARAMS=""
	for dir in "$@"; do
		SCAN_PARAMS+="/mnt/host${dir} "
	done

	mkdir -p /home/docker/clamav/log/ > /dev/null 2>&1
	> /home/docker/clamav/log/scan.log > /dev/null 2>&1

	# Выполнить команду Docker
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		$MOUNT_PARAMS \
		-v /home/docker/clamav/log/:/var/log/clamav/ \
		clamav/clamav-debian:latest \
		clamscan -r --log=/var/log/clamav/scan.log $SCAN_PARAMS

	echo -e "${gl_lv}$@ 扫描完成，病毒报告存放在${gl_huang}/home/docker/clamav/log/scan.log${gl_bai}"
	echo -e "${gl_lv}Если есть вирус, пожалуйста${gl_huang}scan.log${gl_lv}Найдите в файле ключевое слово FOUND, чтобы подтвердить местонахождение вируса.${gl_bai}"

}







clamav() {
		  root_use
		  send_stats "Управление сканированием на вирусы"
		  while true; do
				clear
				echo "инструмент сканирования вирусов clamav"
				echo "Видео-знакомство: https://www.bilibili.com/video/BV1TqvZe4EQm?t=0.1"
				echo "------------------------"
				echo "Это антивирусное программное обеспечение с открытым исходным кодом, которое в основном используется для обнаружения и удаления различных типов вредоносных программ."
				echo "Включает вирусы, троянские кони, шпионское ПО, вредоносные сценарии и другое вредоносное программное обеспечение."
				echo "------------------------"
				echo -e "${gl_lv}1. Полное сканирование${gl_bai}             ${gl_huang}2. Сканируйте важные каталоги${gl_bai}            ${gl_kjlan}3. Выборочное сканирование каталогов.${gl_bai}"
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
				case $sub_choice in
					1)
					  send_stats "Полное сканирование"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /
					  break_end

						;;
					2)
					  send_stats "Сканирование важного каталога"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /etc /var /usr /home /root
					  break_end
						;;
					3)
					  send_stats "Выборочное сканирование каталогов"
					  read -e -p "Введите каталоги для сканирования, разделенные пробелами (например: /etc /var /usr /home /root):" directories
					  install_docker
					  clamav_freshclam
					  clamav_scan $directories
					  break_end
						;;
					*)
					  break  # 跳出循环，退出菜单
						;;
				esac
		  done

}




# Функция оптимизации режима высокой производительности
optimize_high_performance() {
	echo -e "${gl_lv}переключиться на${tiaoyou_moshi}...${gl_bai}"

	echo -e "${gl_lv}Оптимизировать файловые дескрипторы...${gl_bai}"
	ulimit -n 65535

	echo -e "${gl_lv}Оптимизация виртуальной памяти...${gl_bai}"
	sysctl -w vm.swappiness=10 2>/dev/null
	sysctl -w vm.dirty_ratio=15 2>/dev/null
	sysctl -w vm.dirty_background_ratio=5 2>/dev/null
	sysctl -w vm.overcommit_memory=1 2>/dev/null
	sysctl -w vm.min_free_kbytes=65536 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки сети...${gl_bai}"
	sysctl -w net.core.rmem_max=16777216 2>/dev/null
	sysctl -w net.core.wmem_max=16777216 2>/dev/null
	sysctl -w net.core.netdev_max_backlog=250000 2>/dev/null
	sysctl -w net.core.somaxconn=4096 2>/dev/null
	sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216' 2>/dev/null
	sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216' 2>/dev/null
	sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null
	sysctl -w net.ipv4.tcp_max_syn_backlog=8192 2>/dev/null
	sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
	sysctl -w net.ipv4.ip_local_port_range='1024 65535' 2>/dev/null

	echo -e "${gl_lv}Оптимизировать управление кэшем...${gl_bai}"
	sysctl -w vm.vfs_cache_pressure=50 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки процессора...${gl_bai}"
	sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null

	echo -e "${gl_lv}Другие оптимизации...${gl_bai}"
	# Отключите прозрачные огромные страницы, чтобы уменьшить задержку.
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	# Отключить балансировку NUMA
	sysctl -w kernel.numa_balancing=0 2>/dev/null


}

# Функция оптимизации сбалансированного режима
optimize_balanced() {
	echo -e "${gl_lv}Переключиться в режим эквалайзера...${gl_bai}"

	echo -e "${gl_lv}Оптимизировать файловые дескрипторы...${gl_bai}"
	ulimit -n 32768

	echo -e "${gl_lv}Оптимизация виртуальной памяти...${gl_bai}"
	sysctl -w vm.swappiness=30 2>/dev/null
	sysctl -w vm.dirty_ratio=20 2>/dev/null
	sysctl -w vm.dirty_background_ratio=10 2>/dev/null
	sysctl -w vm.overcommit_memory=0 2>/dev/null
	sysctl -w vm.min_free_kbytes=32768 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки сети...${gl_bai}"
	sysctl -w net.core.rmem_max=8388608 2>/dev/null
	sysctl -w net.core.wmem_max=8388608 2>/dev/null
	sysctl -w net.core.netdev_max_backlog=125000 2>/dev/null
	sysctl -w net.core.somaxconn=2048 2>/dev/null
	sysctl -w net.ipv4.tcp_rmem='4096 87380 8388608' 2>/dev/null
	sysctl -w net.ipv4.tcp_wmem='4096 32768 8388608' 2>/dev/null
	sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null
	sysctl -w net.ipv4.tcp_max_syn_backlog=4096 2>/dev/null
	sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
	sysctl -w net.ipv4.ip_local_port_range='1024 49151' 2>/dev/null

	echo -e "${gl_lv}Оптимизировать управление кэшем...${gl_bai}"
	sysctl -w vm.vfs_cache_pressure=75 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки процессора...${gl_bai}"
	sysctl -w kernel.sched_autogroup_enabled=1 2>/dev/null

	echo -e "${gl_lv}Другие оптимизации...${gl_bai}"
	# Восстановить прозрачные огромные страницы
	echo always > /sys/kernel/mm/transparent_hugepage/enabled
	# Восстановление балансировки NUMA
	sysctl -w kernel.numa_balancing=1 2>/dev/null


}

# Функция восстановления настроек по умолчанию
restore_defaults() {
	echo -e "${gl_lv}Вернуться к настройкам по умолчанию...${gl_bai}"

	echo -e "${gl_lv}Восстановить файловые дескрипторы...${gl_bai}"
	ulimit -n 1024

	echo -e "${gl_lv}Восстановить виртуальную память...${gl_bai}"
	sysctl -w vm.swappiness=60 2>/dev/null
	sysctl -w vm.dirty_ratio=20 2>/dev/null
	sysctl -w vm.dirty_background_ratio=10 2>/dev/null
	sysctl -w vm.overcommit_memory=0 2>/dev/null
	sysctl -w vm.min_free_kbytes=16384 2>/dev/null

	echo -e "${gl_lv}Сбросить настройки сети...${gl_bai}"
	sysctl -w net.core.rmem_max=212992 2>/dev/null
	sysctl -w net.core.wmem_max=212992 2>/dev/null
	sysctl -w net.core.netdev_max_backlog=1000 2>/dev/null
	sysctl -w net.core.somaxconn=128 2>/dev/null
	sysctl -w net.ipv4.tcp_rmem='4096 87380 6291456' 2>/dev/null
	sysctl -w net.ipv4.tcp_wmem='4096 16384 4194304' 2>/dev/null
	sysctl -w net.ipv4.tcp_congestion_control=cubic 2>/dev/null
	sysctl -w net.ipv4.tcp_max_syn_backlog=2048 2>/dev/null
	sysctl -w net.ipv4.tcp_tw_reuse=0 2>/dev/null
	sysctl -w net.ipv4.ip_local_port_range='32768 60999' 2>/dev/null

	echo -e "${gl_lv}Восстановить управление кэшем...${gl_bai}"
	sysctl -w vm.vfs_cache_pressure=100 2>/dev/null

	echo -e "${gl_lv}Восстановить настройки процессора...${gl_bai}"
	sysctl -w kernel.sched_autogroup_enabled=1 2>/dev/null

	echo -e "${gl_lv}Отменить другие оптимизации...${gl_bai}"
	# Восстановить прозрачные огромные страницы
	echo always > /sys/kernel/mm/transparent_hugepage/enabled
	# Восстановление балансировки NUMA
	sysctl -w kernel.numa_balancing=1 2>/dev/null

}



# Функция оптимизации построения сайта
optimize_web_server() {
	echo -e "${gl_lv}Переключиться в режим оптимизации построения сайта...${gl_bai}"

	echo -e "${gl_lv}Оптимизировать файловые дескрипторы...${gl_bai}"
	ulimit -n 65535

	echo -e "${gl_lv}Оптимизация виртуальной памяти...${gl_bai}"
	sysctl -w vm.swappiness=10 2>/dev/null
	sysctl -w vm.dirty_ratio=20 2>/dev/null
	sysctl -w vm.dirty_background_ratio=10 2>/dev/null
	sysctl -w vm.overcommit_memory=1 2>/dev/null
	sysctl -w vm.min_free_kbytes=65536 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки сети...${gl_bai}"
	sysctl -w net.core.rmem_max=16777216 2>/dev/null
	sysctl -w net.core.wmem_max=16777216 2>/dev/null
	sysctl -w net.core.netdev_max_backlog=5000 2>/dev/null
	sysctl -w net.core.somaxconn=4096 2>/dev/null
	sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216' 2>/dev/null
	sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216' 2>/dev/null
	sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null
	sysctl -w net.ipv4.tcp_max_syn_backlog=8192 2>/dev/null
	sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
	sysctl -w net.ipv4.ip_local_port_range='1024 65535' 2>/dev/null

	echo -e "${gl_lv}Оптимизировать управление кэшем...${gl_bai}"
	sysctl -w vm.vfs_cache_pressure=50 2>/dev/null

	echo -e "${gl_lv}Оптимизируйте настройки процессора...${gl_bai}"
	sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null

	echo -e "${gl_lv}Другие оптимизации...${gl_bai}"
	# Отключите прозрачные огромные страницы, чтобы уменьшить задержку.
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	# Отключить балансировку NUMA
	sysctl -w kernel.numa_balancing=0 2>/dev/null


}


Kernel_optimize() {
	root_use
	while true; do
	  clear
	  send_stats "Управление настройкой ядра Linux"
	  echo "Оптимизация параметров ядра системы Linux"
	  echo "Видео-знакомство: https://www.bilibili.com/video/BV1Kb421J7yg?t=0.1"
	  echo "------------------------------------------------"
	  echo "Предоставляет различные режимы настройки параметров системы, и пользователи могут переключаться в соответствии со своими сценариями использования."
	  echo -e "${gl_huang}намекать:${gl_bai}Пожалуйста, используйте его с осторожностью в производственной среде!"
	  echo "--------------------"
	  echo "1. Режим высокопроизводительной оптимизации: максимизируйте производительность системы и оптимизируйте файловые дескрипторы, виртуальную память, настройки сети, управление кэшем и настройки ЦП."
	  echo "2. Режим сбалансированной оптимизации: обеспечивает баланс между производительностью и потреблением ресурсов, подходящий для ежедневного использования."
	  echo "3. Режим оптимизации веб-сайта. Оптимизируйте сервер веб-сайта для улучшения возможностей одновременной обработки соединений, скорости ответа и общей производительности."
	  echo "4. Режим оптимизации прямой трансляции: оптимизируйте особые потребности прямой трансляции, чтобы уменьшить задержки и улучшить производительность передачи."
	  echo "5. Режим оптимизации игрового сервера: оптимизируйте игровой сервер для улучшения возможностей одновременной обработки и скорости ответа."
	  echo "6. Восстановить настройки по умолчанию: восстановить настройки системы до конфигурации по умолчанию."
	  echo "--------------------"
	  echo "0. Вернуться в предыдущее меню"
	  echo "--------------------"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
	  case $sub_choice in
		  1)
			  cd ~
			  clear
			  local tiaoyou_moshi="Режим оптимизации высокой производительности"
			  optimize_high_performance
			  send_stats "Оптимизация режима высокой производительности"
			  ;;
		  2)
			  cd ~
			  clear
			  optimize_balanced
			  send_stats "Оптимизация сбалансированного режима"
			  ;;
		  3)
			  cd ~
			  clear
			  optimize_web_server
			  send_stats "Модель оптимизации сайта"
			  ;;
		  4)
			  cd ~
			  clear
			  local tiaoyou_moshi="Режим оптимизации прямой трансляции"
			  optimize_high_performance
			  send_stats "Оптимизация прямых трансляций"
			  ;;
		  5)
			  cd ~
			  clear
			  local tiaoyou_moshi="Режим оптимизации игрового сервера"
			  optimize_high_performance
			  send_stats "Оптимизация игрового сервера"
			  ;;
		  6)
			  cd ~
			  clear
			  restore_defaults
			  send_stats "Восстановить настройки по умолчанию"
			  ;;
		  *)
			  break
			  ;;
	  esac
	  break_end
	done
}





update_locale() {
	local lang=$1
	local locale_file=$2

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case $ID in
			debian|ubuntu|kali)
				install locales
				sed -i "s/^\s*#\?\s*${locale_file}/${locale_file}/" /etc/locale.gen
				locale-gen
				echo "LANG=${lang}" > /etc/default/locale
				export LANG=${lang}
				echo -e "${gl_lv}Язык системы был изменен и теперь:$langПовторно подключитесь к SSH, чтобы изменения вступили в силу.${gl_bai}"
				hash -r
				break_end

				;;
			centos|rhel|almalinux|rocky|fedora)
				install glibc-langpack-zh
				localectl set-locale LANG=${lang}
				echo "LANG=${lang}" | tee /etc/locale.conf
				echo -e "${gl_lv}Язык системы был изменен и теперь:$langПовторно подключитесь к SSH, чтобы изменения вступили в силу.${gl_bai}"
				hash -r
				break_end
				;;
			*)
				echo "Неподдерживаемые системы:$ID"
				break_end
				;;
		esac
	else
		echo "Неподдерживаемая система, тип системы не может быть идентифицирован."
		break_end
	fi
}




linux_language() {
root_use
send_stats "Переключить язык системы"
while true; do
  clear
  echo "Текущий язык системы:$LANG"
  echo "------------------------"
  echo "1. Английский 2. Упрощенный китайский 3. Традиционный китайский"
  echo "------------------------"
  echo "0. Вернуться в предыдущее меню"
  echo "------------------------"
  read -e -p "Введите свой выбор:" choice

  case $choice in
	  1)
		  update_locale "en_US.UTF-8" "en_US.UTF-8"
		  send_stats "переключиться на английский"
		  ;;
	  2)
		  update_locale "zh_CN.UTF-8" "zh_CN.UTF-8"
		  send_stats "Переключиться на упрощенный китайский"
		  ;;
	  3)
		  update_locale "zh_TW.UTF-8" "zh_TW.UTF-8"
		  send_stats "Переключиться на традиционный китайский"
		  ;;
	  *)
		  break
		  ;;
  esac
done
}



shell_bianse_profile() {

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	sed -i '/^PS1=/d' ~/.bashrc
	echo "${bianse}" >> ~/.bashrc
	# source ~/.bashrc
else
	sed -i '/^PS1=/d' ~/.profile
	echo "${bianse}" >> ~/.profile
	# source ~/.profile
fi
echo -e "${gl_lv}Изменение завершено. Повторно подключитесь к SSH, чтобы увидеть изменения!${gl_bai}"

hash -r
break_end

}



shell_bianse() {
  root_use
  send_stats "Инструмент украшения командной строки"
  while true; do
	clear
	echo "Инструмент украшения командной строки"
	echo "------------------------"
	echo -e "1. \033[1;32mroot \033[1;34mlocalhost \033[1;31m~ \033[0m${gl_bai}#"
	echo -e "2. \033[1;35mroot \033[1;36mlocalhost \033[1;33m~ \033[0m${gl_bai}#"
	echo -e "3. \033[1;31mroot \033[1;32mlocalhost \033[1;34m~ \033[0m${gl_bai}#"
	echo -e "4. \033[1;36mroot \033[1;33mlocalhost \033[1;37m~ \033[0m${gl_bai}#"
	echo -e "5. \033[1;37mroot \033[1;31mlocalhost \033[1;32m~ \033[0m${gl_bai}#"
	echo -e "6. \033[1;33mroot \033[1;34mlocalhost \033[1;35m~ \033[0m${gl_bai}#"
	echo -e "7. root localhost ~ #"
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Введите свой выбор:" choice

	case $choice in
	  1)
		local bianse="PS1='\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;31m\]\w\[\033[0m\] # '"
		shell_bianse_profile

		;;
	  2)
		local bianse="PS1='\[\033[1;35m\]\u\[\033[0m\]@\[\033[1;36m\]\h\[\033[0m\] \[\033[1;33m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  3)
		local bianse="PS1='\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  4)
		local bianse="PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;33m\]\h\[\033[0m\] \[\033[1;37m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  5)
		local bianse="PS1='\[\033[1;37m\]\u\[\033[0m\]@\[\033[1;31m\]\h\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  6)
		local bianse="PS1='\[\033[1;33m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;35m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  7)
		local bianse=""
		shell_bianse_profile
		;;
	  *)
		break
		;;
	esac

  done
}




linux_trash() {
  root_use
  send_stats "Системная корзина"

  local bashrc_profile="/root/.bashrc"
  local TRASH_DIR="$HOME/.local/share/Trash/files"

  while true; do

	local trash_status
	if ! grep -q "trash-put" "$bashrc_profile"; then
		trash_status="${gl_hui}Не включено${gl_bai}"
	else
		trash_status="${gl_lv}Включено${gl_bai}"
	fi

	clear
	echo -e "Текущая корзина${trash_status}"
	echo -e "После включения файлы, удаленные rm, сначала будут помещены в корзину, чтобы предотвратить случайное удаление важных файлов!"
	echo "------------------------------------------------"
	ls -l --color=auto "$TRASH_DIR" 2>/dev/null || echo "Корзина пуста"
	echo "------------------------"
	echo "1. Включить корзину 2. Закрыть корзину"
	echo "3. Восстановить содержимое. 4. Очистить корзину."
	echo "------------------------"
	echo "0. Вернуться в предыдущее меню"
	echo "------------------------"
	read -e -p "Введите свой выбор:" choice

	case $choice in
	  1)
		install trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='trash-put'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "Корзина включена, удаленные файлы будут перемещены в корзину."
		sleep 2
		;;
	  2)
		remove trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='rm -i'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "Корзина закрывается, и файлы будут удалены напрямую."
		sleep 2
		;;
	  3)
		read -e -p "Введите имя файла, который необходимо восстановить:" file_to_restore
		if [ -e "$TRASH_DIR/$file_to_restore" ]; then
		  mv "$TRASH_DIR/$file_to_restore" "$HOME/"
		  echo "$file_to_restoreВосстановлен в домашний каталог."
		else
		  echo "Файл не существует."
		fi
		;;
	  4)
		read -e -p "Вы уверены, что хотите очистить корзину? [да/нет]:" confirm
		if [[ "$confirm" == "y" ]]; then
		  trash-empty
		  echo "Корзина очищена."
		fi
		;;
	  *)
		break
		;;
	esac
  done
}

linux_fav() {
send_stats "Избранное команд"
bash <(curl -l -s ${gh_proxy}raw.githubusercontent.com/byJoey/cmdbox/refs/heads/main/install.sh)
}

# Создать резервную копию
create_backup() {
	send_stats "Создать резервную копию"
	local TIMESTAMP=$(date +"%Y%m%d%H%M%S")

	# Запросить у пользователя каталог резервной копии
	echo "Пример создания резервной копии:"
	echo "- Создайте резервную копию одного каталога: /var/www."
	echo "- Резервное копирование нескольких каталогов: /etc/home/var/log"
	echo "- Нажмите Enter, чтобы использовать каталог по умолчанию (/etc/usr/home)."
	read -e -p "Введите каталог для резервного копирования (разделите несколько каталогов пробелами и нажмите Enter, чтобы использовать каталог по умолчанию):" input

	# Если пользователь не вводит каталог, используется каталог по умолчанию.
	if [ -z "$input" ]; then
		BACKUP_PATHS=(
			"/etc"              # 配置文件和软件包配置
			"/usr"              # 已安装的软件文件
			"/home"             # 用户数据
		)
	else
		# Разделяйте каталоги, введенные пользователем, в массив пробелами.
		IFS=' ' read -r -a BACKUP_PATHS <<< "$input"
	fi

	# Создать префикс файла резервной копии
	local PREFIX=""
	for path in "${BACKUP_PATHS[@]}"; do
		# Извлеките имя каталога и удалите косую черту
		dir_name=$(basename "$path")
		PREFIX+="${dir_name}_"
	done

	# Удалить последнее подчеркивание
	local PREFIX=${PREFIX%_}

	# Создать имя файла резервной копии
	local BACKUP_NAME="${PREFIX}_$TIMESTAMP.tar.gz"

	# Каталог печати, выбранный пользователем
	echo "Выбранный вами каталог резервной копии:"
	for path in "${BACKUP_PATHS[@]}"; do
		echo "- $path"
	done

	# Создать резервную копию
	echo "Создание резервной копии$BACKUP_NAME..."
	install tar
	tar -czvf "$BACKUP_DIR/$BACKUP_NAME" "${BACKUP_PATHS[@]}"

	# Проверьте, была ли команда успешной
	if [ $? -eq 0 ]; then
		echo "Резервная копия успешно создана:$BACKUP_DIR/$BACKUP_NAME"
	else
		echo "Не удалось создать резервную копию!"
		exit 1
	fi
}

# Восстановить резервную копию
restore_backup() {
	send_stats "Восстановить резервную копию"
	# Выберите резервную копию для восстановления
	read -e -p "Пожалуйста, введите имя файла резервной копии, который необходимо восстановить:" BACKUP_NAME

	# Проверьте, существует ли файл резервной копии
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "Файл резервной копии не существует!"
		exit 1
	fi

	echo "Восстановление резервной копии$BACKUP_NAME..."
	tar -xzvf "$BACKUP_DIR/$BACKUP_NAME" -C /

	if [ $? -eq 0 ]; then
		echo "Резервное копирование и восстановление успешно!"
	else
		echo "Восстановление резервной копии не удалось!"
		exit 1
	fi
}

# Получение списка резервных копий
list_backups() {
	echo "Доступные резервные копии:"
	ls -1 "$BACKUP_DIR"
}

# Удалить резервную копию
delete_backup() {
	send_stats "Удалить резервную копию"

	read -e -p "Пожалуйста, введите имя файла резервной копии, который необходимо удалить:" BACKUP_NAME

	# Проверьте, существует ли файл резервной копии
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "Файл резервной копии не существует!"
		exit 1
	fi

	# Удалить резервную копию
	rm -f "$BACKUP_DIR/$BACKUP_NAME"

	if [ $? -eq 0 ]; then
		echo "Резервная копия успешно удалена!"
	else
		echo "Удаление резервной копии не удалось!"
		exit 1
	fi
}

# Главное меню резервного копирования
linux_backup() {
	BACKUP_DIR="/backups"
	mkdir -p "$BACKUP_DIR"
	while true; do
		clear
		send_stats "Функция резервного копирования системы"
		echo "Функция резервного копирования системы"
		echo "------------------------"
		list_backups
		echo "------------------------"
		echo "1. Создать резервную копию 2. Восстановить резервную копию 3. Удалить резервную копию"
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" choice
		case $choice in
			1) create_backup ;;
			2) restore_backup ;;
			3) delete_backup ;;
			*) break ;;
		esac
		read -e -p "Нажмите Enter, чтобы продолжить..."
	done
}









# Показать список подключений
list_connections() {
	echo "Сохраненные соединения:"
	echo "------------------------"
	cat "$CONFIG_FILE" | awk -F'|' '{print NR " - " $1 " (" $2 ")"}'
	echo "------------------------"
}


# Добавить новое соединение
add_connection() {
	send_stats "Добавить новое соединение"
	echo "Пример создания нового соединения:"
	echo "- Имя соединения: my_server"
	echo "- IP-адрес: 192.168.1.100"
	echo "- Имя пользователя: root"
	echo "- Порт: 22"
	echo "------------------------"
	read -e -p "Пожалуйста, введите имя подключения:" name
	read -e -p "Пожалуйста, введите IP-адрес:" ip
	read -e -p "Пожалуйста, введите имя пользователя (по умолчанию: root):" user
	local user=${user:-root}  # 如果用户未输入，则使用默认值 root
	read -e -p "Пожалуйста, введите номер порта (по умолчанию: 22):" port
	local port=${port:-22}  # 如果用户未输入，则使用默认值 22

	echo "Пожалуйста, выберите метод аутентификации:"
	echo "1. Пароль"
	echo "2. Ключ"
	read -e -p "Пожалуйста, введите ваш выбор (1/2):" auth_choice

	case $auth_choice in
		1)
			read -s -p "Пожалуйста, введите пароль:" password_or_key
			echo  # 换行
			;;
		2)
			echo "Вставьте ключевое содержимое (дважды нажмите Enter после вставки):"
			local password_or_key=""
			while IFS= read -r line; do
				# Если ввод представляет собой пустую строку, а содержание ключа уже содержит начало, завершите ввод.
				if [[ -z "$line" && "$password_or_key" == *"-----BEGIN"* ]]; then
					break
				fi
				# Если это первая строка или вы уже начали вводить ключевое содержание, продолжайте добавлять
				if [[ -n "$line" || "$password_or_key" == *"-----BEGIN"* ]]; then
					local password_or_key+="${line}"$'\n'
				fi
			done

			# Проверьте, является ли это ключевым контентом
			if [[ "$password_or_key" == *"-----BEGIN"* && "$password_or_key" == *"PRIVATE KEY-----"* ]]; then
				local key_file="$KEY_DIR/$name.key"
				echo -n "$password_or_key" > "$key_file"
				chmod 600 "$key_file"
				local password_or_key="$key_file"
			fi
			;;
		*)
			echo "Неверный выбор!"
			return
			;;
	esac

	echo "$name|$ip|$user|$port|$password_or_key" >> "$CONFIG_FILE"
	echo "Соединение сохранено!"
}



# Удалить соединение
delete_connection() {
	send_stats "Удалить соединение"
	read -e -p "Пожалуйста, введите номер соединения, которое необходимо удалить:" num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "Ошибка: Соответствующее соединение не найдено."
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	# Если соединение использует файл ключа, удалите файл ключа.
	if [[ "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "Соединение удалено!"
}

# Использовать соединение
use_connection() {
	send_stats "Использовать соединение"
	read -e -p "Пожалуйста, введите номер подключения для использования:" num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "Ошибка: Соответствующее соединение не найдено."
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	echo "Подключение к$name ($ip)..."
	if [[ -f "$password_or_key" ]]; then
		# Подключиться с помощью ключа
		ssh -o StrictHostKeyChecking=no -i "$password_or_key" -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "Соединение не удалось! Пожалуйста, проверьте следующее:"
			echo "1. Правильный ли путь к файлу ключей?$password_or_key"
			echo "2. Правильны ли права доступа к ключевому файлу (должно быть 600)."
			echo "3. Разрешает ли целевой сервер вход в систему с использованием ключа."
		fi
	else
		# Подключиться с помощью пароля
		if ! command -v sshpass &> /dev/null; then
			echo "Ошибка: sshpass не установлен, сначала установите sshpass."
			echo "Способ установки:"
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" ssh -o StrictHostKeyChecking=no -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "Соединение не удалось! Пожалуйста, проверьте следующее:"
			echo "1. Правильно ли указаны имя пользователя и пароль?"
			echo "2. Разрешает ли целевой сервер вход по паролю."
			echo "3. Нормально ли работает служба SSH целевого сервера."
		fi
	fi
}


ssh_manager() {
	send_stats "инструмент удаленного подключения ssh"

	CONFIG_FILE="$HOME/.ssh_connections"
	KEY_DIR="$HOME/.ssh/ssh_manager_keys"

	# Проверьте, существуют ли файл конфигурации и каталог ключей, создайте их, если они не существуют.
	if [[ ! -f "$CONFIG_FILE" ]]; then
		touch "$CONFIG_FILE"
	fi

	if [[ ! -d "$KEY_DIR" ]]; then
		mkdir -p "$KEY_DIR"
		chmod 700 "$KEY_DIR"
	fi

	while true; do
		clear
		echo "Инструмент удаленного подключения SSH"
		echo "Может подключаться к другим системам Linux через SSH."
		echo "------------------------"
		list_connections
		echo "1. Создать новое соединение 2. Использовать соединение 3. Удалить соединение"
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" choice
		case $choice in
			1) add_connection ;;
			2) use_connection ;;
			3) delete_connection ;;
			0) break ;;
			*) echo "Неверный выбор, попробуйте еще раз." ;;
		esac
	done
}












# Список доступных разделов жесткого диска
list_partitions() {
	echo "Доступные разделы жесткого диска:"
	lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v "sr\|loop"
}


# Постоянно монтируемый раздел
mount_partition() {
	send_stats "Смонтировать раздел"
	read -e -p "Введите имя монтируемого раздела (например, sda1):" PARTITION

	DEVICE="/dev/$PARTITION"
	MOUNT_POINT="/mnt/$PARTITION"

	# Проверьте, существует ли раздел
	if ! lsblk -no NAME | grep -qw "$PARTITION"; then
		echo "Раздел не существует!"
		return 1
	fi

	# Проверьте, установлен ли он
	if mount | grep -qw "$DEVICE"; then
		echo "Раздел смонтирован!"
		return 1
	fi

	# Получить UUID
	UUID=$(blkid -s UUID -o value "$DEVICE")
	if [ -z "$UUID" ]; then
		echo "Невозможно получить UUID!"
		return 1
	fi

	# Получить тип файловой системы
	FSTYPE=$(blkid -s TYPE -o value "$DEVICE")
	if [ -z "$FSTYPE" ]; then
		echo "Невозможно получить тип файловой системы!"
		return 1
	fi

	# Создать точку монтирования
	mkdir -p "$MOUNT_POINT"

	# устанавливать
	if ! mount "$DEVICE" "$MOUNT_POINT"; then
		echo "Монтирование раздела не удалось!"
		rmdir "$MOUNT_POINT"
		return 1
	fi

	echo "Раздел был успешно смонтирован в$MOUNT_POINT"

	# Проверьте /etc/fstab, чтобы узнать, существует ли UUID или точка монтирования.
	if grep -qE "UUID=$UUID|[[:space:]]$MOUNT_POINT[[:space:]]" /etc/fstab; then
		echo "Запись раздела уже существует в /etc/fstab, пропустите запись"
		return 0
	fi

	# Напишите в /etc/fstab
	echo "UUID=$UUID $MOUNT_POINT $FSTYPE defaults,nofail 0 2" >> /etc/fstab

	echo "Записано в /etc/fstab для обеспечения постоянного монтирования."
}


# Размонтировать раздел
unmount_partition() {
	send_stats "Размонтировать раздел"
	read -e -p "Введите имя раздела, который нужно размонтировать (например, sda1):" PARTITION

	# Проверьте, смонтирован ли раздел
	MOUNT_POINT=$(lsblk -o MOUNTPOINT | grep -w "$PARTITION")
	if [ -z "$MOUNT_POINT" ]; then
		echo "Раздел не монтируется!"
		return
	fi

	# Размонтировать раздел
	umount "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "Раздел успешно удален:$MOUNT_POINT"
		rmdir "$MOUNT_POINT"
	else
		echo "Удаление раздела не удалось!"
	fi
}

# Список смонтированных разделов
list_mounted_partitions() {
	echo "Установленный раздел:"
	df -h | grep -v "tmpfs\|udev\|overlay"
}

# Форматировать раздел
format_partition() {
	send_stats "Форматировать раздел"
	read -e -p "Введите имя раздела, который нужно отформатировать (например, sda1):" PARTITION

	# Проверьте, существует ли раздел
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "Раздел не существует!"
		return
	fi

	# Проверьте, смонтирован ли раздел
	if lsblk -o MOUNTPOINT | grep -w "$PARTITION" > /dev/null; then
		echo "Раздел смонтирован, сначала отключите его!"
		return
	fi

	# Выберите тип файловой системы
	echo "Пожалуйста, выберите тип файловой системы:"
	echo "1. ext4"
	echo "2. xfs"
	echo "3. ntfs"
	echo "4. vfat"
	read -e -p "Пожалуйста, введите ваш выбор:" FS_CHOICE

	case $FS_CHOICE in
		1) FS_TYPE="ext4" ;;
		2) FS_TYPE="xfs" ;;
		3) FS_TYPE="ntfs" ;;
		4) FS_TYPE="vfat" ;;
		*) echo "Неверный выбор!"; return ;;
	esac

	# Подтвердите форматирование
	read -e -p "Подтвердите форматирование раздела /dev/$PARTITIONдля$FS_TYPE? (да/нет):" CONFIRM
	if [ "$CONFIRM" != "y" ]; then
		echo "Операция отменена."
		return
	fi

	# Форматировать раздел
	echo "Форматирование раздела /dev/$PARTITIONдля$FS_TYPE ..."
	mkfs.$FS_TYPE "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "Раздел успешно отформатирован!"
	else
		echo "Форматирование раздела не удалось!"
	fi
}

# Проверить статус раздела
check_partition() {
	send_stats "Проверить статус раздела"
	read -e -p "Введите имя раздела для проверки (например, sda1):" PARTITION

	# Проверьте, существует ли раздел
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "Раздел не существует!"
		return
	fi

	# Проверить статус раздела
	echo "Проверьте раздел /dev/$PARTITIONстатус:"
	fsck "/dev/$PARTITION"
}

# Главное меню
disk_manager() {
	send_stats "Функция управления жестким диском"
	while true; do
		clear
		echo "Управление разделами жесткого диска"
		echo -e "${gl_huang}Эта функция находится на внутреннем тестировании и не должна использоваться в производственной среде.${gl_bai}"
		echo "------------------------"
		list_partitions
		echo "------------------------"
		echo "1. Подключите раздел 2. Отключите раздел 3. Просмотрите смонтированный раздел"
		echo "4. Отформатируйте раздел. 5. Проверьте состояние раздела."
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" choice
		case $choice in
			1) mount_partition ;;
			2) unmount_partition ;;
			3) list_mounted_partitions ;;
			4) format_partition ;;
			5) check_partition ;;
			*) break ;;
		esac
		read -e -p "Нажмите Enter, чтобы продолжить..."
	done
}




# Показать список задач
list_tasks() {
	echo "Сохраненные задачи синхронизации:"
	echo "---------------------------------"
	awk -F'|' '{print NR " - " $1 " ( " $2 " -> " $3":"$4 " )"}' "$CONFIG_FILE"
	echo "---------------------------------"
}

# Добавить новую задачу
add_task() {
	send_stats "Добавить новую задачу синхронизации"
	echo "Пример создания новой задачи синхронизации:"
	echo "- Имя задачи: backup_www."
	echo "- Локальный каталог: /var/www"
	echo "- Удаленный адрес: user@192.168.1.100."
	echo "- Удаленный каталог: /backup/www."
	echo "- Номер порта (по умолчанию 22)"
	echo "---------------------------------"
	read -e -p "Пожалуйста, введите название задачи:" name
	read -e -p "Пожалуйста, введите локальный каталог:" local_path
	read -e -p "Пожалуйста, введите удаленный каталог:" remote_path
	read -e -p "Пожалуйста, введите удаленный user@IP:" remote
	read -e -p "Пожалуйста, введите порт SSH (по умолчанию 22):" port
	port=${port:-22}

	echo "Пожалуйста, выберите метод аутентификации:"
	echo "1. Пароль"
	echo "2. Ключ"
	read -e -p "Пожалуйста, выберите (1/2):" auth_choice

	case $auth_choice in
		1)
			read -s -p "Пожалуйста, введите пароль:" password_or_key
			echo  # 换行
			auth_method="password"
			;;
		2)
			echo "Вставьте ключевое содержимое (дважды нажмите Enter после вставки):"
			local password_or_key=""
			while IFS= read -r line; do
				# Если ввод представляет собой пустую строку, а содержание ключа уже содержит начало, завершите ввод.
				if [[ -z "$line" && "$password_or_key" == *"-----BEGIN"* ]]; then
					break
				fi
				# Если это первая строка или вы уже начали вводить ключевое содержание, продолжайте добавлять
				if [[ -n "$line" || "$password_or_key" == *"-----BEGIN"* ]]; then
					password_or_key+="${line}"$'\n'
				fi
			done

			# Проверьте, является ли это ключевым контентом
			if [[ "$password_or_key" == *"-----BEGIN"* && "$password_or_key" == *"PRIVATE KEY-----"* ]]; then
				local key_file="$KEY_DIR/${name}_sync.key"
				echo -n "$password_or_key" > "$key_file"
				chmod 600 "$key_file"
				password_or_key="$key_file"
				auth_method="key"
			else
				echo "Неверное содержание ключа!"
				return
			fi
			;;
		*)
			echo "Неверный выбор!"
			return
			;;
	esac

	echo "Пожалуйста, выберите режим синхронизации:"
	echo "1. Стандартный режим (-avz)"
	echo "2. Удалить целевой файл (-avz --delete)"
	read -e -p "Пожалуйста, выберите (1/2):" mode
	case $mode in
		1) options="-avz" ;;
		2) options="-avz --delete" ;;
		*) echo "Неверный выбор, используйте -avz по умолчанию."; options="-avz" ;;
	esac

	echo "$name|$local_path|$remote|$remote_path|$port|$options|$auth_method|$password_or_key" >> "$CONFIG_FILE"

	install rsync rsync

	echo "Миссия сохранена!"
}

# Удалить задачу
delete_task() {
	send_stats "Удалить задачу синхронизации"
	read -e -p "Пожалуйста, введите номер задачи, которую необходимо удалить:" num

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "Ошибка: Соответствующая задача не найдена."
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# Если задача использует файл ключа, удалите файл ключа.
	if [[ "$auth_method" == "key" && "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "Задача удалена!"
}


run_task() {
	send_stats "Выполнение задач синхронизации"

	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	# Параметры анализа
	local direction="push"  # 默认是推送到远端
	local num

	if [[ "$1" == "push" || "$1" == "pull" ]]; then
		direction="$1"
		num="$2"
	else
		num="$1"
	fi

	# Если номер задачи не передан, пользователю будет предложено ввести
	if [[ -z "$num" ]]; then
		read -e -p "Введите номер задачи, которую необходимо выполнить:" num
	fi

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "Ошибка: Задача не найдена!"
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# Настройте пути источника и назначения в зависимости от направления синхронизации.
	if [[ "$direction" == "pull" ]]; then
		echo "Вытягивание и синхронизация с локальным:$remote:$local_path -> $remote_path"
		source="$remote:$local_path"
		destination="$remote_path"
	else
		echo "Отправка и синхронизация с удаленным концом:$local_path -> $remote:$remote_path"
		source="$local_path"
		destination="$remote:$remote_path"
	fi

	# Добавить общие параметры SSH-соединения
	local ssh_options="-p $port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

	if [[ "$auth_method" == "password" ]]; then
		if ! command -v sshpass &> /dev/null; then
			echo "Ошибка: sshpass не установлен, сначала установите sshpass."
			echo "Способ установки:"
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" rsync $options -e "ssh $ssh_options" "$source" "$destination"
	else
		# Проверьте, существует ли файл ключа и правильны ли разрешения.
		if [[ ! -f "$password_or_key" ]]; then
			echo "Ошибка: Файл ключа не существует:$password_or_key"
			return
		fi

		if [[ "$(stat -c %a "$password_or_key")" != "600" ]]; then
			echo "Предупреждение: неправильные права доступа к файлу ключей, исправление..."
			chmod 600 "$password_or_key"
		fi

		rsync $options -e "ssh -i $password_or_key $ssh_options" "$source" "$destination"
	fi

	if [[ $? -eq 0 ]]; then
		echo "Синхронизация завершена!"
	else
		echo "Синхронизация не удалась! Пожалуйста, проверьте следующее:"
		echo "1. Сетевое соединение нормальное?"
		echo "2. Доступен ли удаленный хост"
		echo "3. Верна ли информация аутентификации?"
		echo "4. Имеют ли локальный и удаленный каталог правильные права доступа?"
	fi
}


# Создать запланированную задачу
schedule_task() {
	send_stats "Добавить запланированные задачи синхронизации"

	read -e -p "Пожалуйста, введите номер задачи для регулярной синхронизации:" num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "Ошибка: Введите действительный номер задачи!"
		return
	fi

	echo "Пожалуйста, выберите запланированный интервал выполнения:"
	echo "1) Выполнять раз в час"
	echo "2) Выполнять один раз в день"
	echo "3) Выполнять раз в неделю."
	read -e -p "Пожалуйста, введите варианты (1/2/3):" interval

	local random_minute=$(shuf -i 0-59 -n 1)  # 生成 0-59 之间的随机分钟数
	local cron_time=""
	case "$interval" in
		1) cron_time="$random_minute * * * *" ;;  # 每小时，随机分钟执行
		2) cron_time="$random_minute 0 * * *" ;;  # 每天，随机分钟执行
		3) cron_time="$random_minute 0 * * 1" ;;  # 每周，随机分钟执行
		*) echo "Ошибка: Введите допустимые параметры!" ; return ;;
	esac

	local cron_job="$cron_time k rsync_run $num"
	local cron_job="$cron_time k rsync_run $num"

	# Проверьте, существует ли уже такая задача
	if crontab -l | grep -q "k rsync_run $num"; then
		echo "Ошибка: запланированная синхронизация для этой задачи уже существует!"
		return
	fi

	# Создать в crontab пользователя
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "Запланированная задача создана:$cron_job"
}

# Просмотр запланированных задач
view_tasks() {
	echo "Текущие запланированные задачи:"
	echo "---------------------------------"
	crontab -l | grep "k rsync_run"
	echo "---------------------------------"
}

# Удалить запланированные задачи
delete_task_schedule() {
	send_stats "Удаление запланированных задач синхронизации"
	read -e -p "Пожалуйста, введите номер задачи, которую необходимо удалить:" num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "Ошибка: Введите действительный номер задачи!"
		return
	fi

	crontab -l | grep -v "k rsync_run $num" | crontab -
	echo "Номер задачи удален.$numзапланированные задачи"
}


# Главное меню управления задачами
rsync_manager() {
	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	while true; do
		clear
		echo "Инструмент удаленной синхронизации Rsync"
		echo "Синхронизация между удаленными каталогами поддерживает инкрементную синхронизацию, которая является эффективной и стабильной."
		echo "---------------------------------"
		list_tasks
		echo
		view_tasks
		echo
		echo "1. Создать новую задачу 2. Удалить задачу"
		echo "3. Выполните локальную синхронизацию с удаленным сайтом. 4. Выполните удаленную синхронизацию с локальным сайтом."
		echo "5. Создать запланированное задание 6. Удалить запланированное задание"
		echo "---------------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "---------------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" choice
		case $choice in
			1) add_task ;;
			2) delete_task ;;
			3) run_task push;;
			4) run_task pull;;
			5) schedule_task ;;
			6) delete_task_schedule ;;
			0) break ;;
			*) echo "Неверный выбор, попробуйте еще раз." ;;
		esac
		read -e -p "Нажмите Enter, чтобы продолжить..."
	done
}









linux_info() {



	clear
	echo -e "${gl_kjlan}Запрос системной информации...${gl_bai}"
	send_stats "Запрос информации о системе"

	ip_address

	local cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

	local cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
		<(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))

	local cpu_cores=$(nproc)

	local cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')

	local mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2fM (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

	local disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

	local ipinfo=$(curl -s ipinfo.io)
	local country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
	local city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
	local isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')

	local load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')
	local dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)


	local cpu_arch=$(uname -m)

	local hostname=$(uname -n)

	local kernel_version=$(uname -r)

	local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
	local queue_algorithm=$(sysctl -n net.core.default_qdisc)

	local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')

	output_status

	local current_time=$(date "+%Y-%m-%d %I:%M %p")


	local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

	local runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1% 3600) / 60); if (run_days > 0) printf("%d day ", run_days); if (run_hours > 0) printf("%dhour", run_hours); printf("%d минута\n", run_минуты)}')

	local timezone=$(current_timezone)

	local tcp_count=$(ss -t | wc -l)
	local udp_count=$(ss -u | wc -l)

	clear
	echo -e "Запрос информации о системе"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Имя хоста:${gl_bai}$hostname"
	echo -e "${gl_kjlan}Версия системы:${gl_bai}$os_info"
	echo -e "${gl_kjlan}Версия Linux:${gl_bai}$kernel_version"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Архитектура процессора:${gl_bai}$cpu_arch"
	echo -e "${gl_kjlan}Модель процессора:${gl_bai}$cpu_info"
	echo -e "${gl_kjlan}Количество ядер процессора:${gl_bai}$cpu_cores"
	echo -e "${gl_kjlan}Частота процессора:${gl_bai}$cpu_freq"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Использование процессора:${gl_bai}$cpu_usage_percent%"
	echo -e "${gl_kjlan}Загрузка системы:${gl_bai}$load"
	echo -e "${gl_kjlan}Количество TCP|UDP-соединений:${gl_bai}$tcp_count|$udp_count"
	echo -e "${gl_kjlan}Физическая память:${gl_bai}$mem_info"
	echo -e "${gl_kjlan}Виртуальная память:${gl_bai}$swap_info"
	echo -e "${gl_kjlan}Использование жесткого диска:${gl_bai}$disk_info"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Всего получено:${gl_bai}$rx"
	echo -e "${gl_kjlan}Всего отправлено:${gl_bai}$tx"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Сетевой алгоритм:${gl_bai}$congestion_algorithm $queue_algorithm"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Оператор:${gl_bai}$isp_info"
	if [ -n "$ipv4_address" ]; then
		echo -e "${gl_kjlan}IPv4-адрес:${gl_bai}$ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo -e "${gl_kjlan}IPv6-адрес:${gl_bai}$ipv6_address"
	fi
	echo -e "${gl_kjlan}DNS-адрес:${gl_bai}$dns_addresses"
	echo -e "${gl_kjlan}Расположение:${gl_bai}$country $city"
	echo -e "${gl_kjlan}Системное время:${gl_bai}$timezone $current_time"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}Время работы:${gl_bai}$runtime"
	echo



}



linux_tools() {

  while true; do
	  clear
	  # send_stats «Основные инструменты»
	  echo -e "основные инструменты"

	  tools=(
		curl wget sudo socat htop iftop unzip tar tmux ffmpeg
		btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders
		vim nano git
	  )

	  if command -v apt >/dev/null 2>&1; then
		PM="apt"
	  elif command -v dnf >/dev/null 2>&1; then
		PM="dnf"
	  elif command -v yum >/dev/null 2>&1; then
		PM="yum"
	  elif command -v pacman >/dev/null 2>&1; then
		PM="pacman"
	  elif command -v apk >/dev/null 2>&1; then
		PM="apk"
	  elif command -v zypper >/dev/null 2>&1; then
		PM="zypper"
	  elif command -v opkg >/dev/null 2>&1; then
		PM="opkg"
	  elif command -v pkg >/dev/null 2>&1; then
		PM="pkg"
	  else
		echo "❌ Нераспознанный менеджер пакетов"
		exit 1
	  fi

	  echo "📦 Используйте менеджер пакетов:$PM"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"

	  for ((i=0; i<${#tools[@]}; i+=2)); do
		# левый столбец
		if command -v "${tools[i]}" >/dev/null 2>&1; then
		  left=$(printf "✅ %-12 установлено" "${tools[i]}")
		else
		  left=$(printf "❌ %-12 не установлены" "${tools[i]}")
		fi

		# Правый столбец (чтобы предотвратить выход массива за пределы)
		if [[ -n "${tools[i+1]}" ]]; then
		  if command -v "${tools[i+1]}" >/dev/null 2>&1; then
			right=$(printf "✅ %-12 установлено" "${tools[i+1]}")
		  else
			right=$(printf "❌ %-12 не установлены" "${tools[i+1]}")
		  fi
		  printf "%-42s %s\n" "$left" "$right"
		else
		  printf "%s\n" "$left"
		fi
	  done

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}инструмент для загрузки завитков${gl_huang}★${gl_bai}                   ${gl_kjlan}2.   ${gl_bai}инструмент загрузки wget${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}3.   ${gl_bai}инструмент суперадминистративных привилегий sudo${gl_kjlan}4.   ${gl_bai}инструмент для подключения socat-связи"
	  echo -e "${gl_kjlan}5.   ${gl_bai}инструмент мониторинга системы htop${gl_kjlan}6.   ${gl_bai}инструмент мониторинга сетевого трафика iftop"
	  echo -e "${gl_kjlan}7.   ${gl_bai}инструмент для сжатия и распаковки ZIP${gl_kjlan}8.   ${gl_bai}Инструмент сжатия и распаковки tar GZ"
	  echo -e "${gl_kjlan}9.   ${gl_bai}инструмент многоканального фонового запуска tmux${gl_kjlan}10.  ${gl_bai}инструмент для кодирования видео в реальном времени ffmpeg"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}современный инструмент мониторинга btop${gl_huang}★${gl_bai}             ${gl_kjlan}12.  ${gl_bai}инструмент управления файлами рейнджера"
	  echo -e "${gl_kjlan}13.  ${gl_bai}Инструмент просмотра использования диска ncdu${gl_kjlan}14.  ${gl_bai}инструмент глобального поиска fzf"
	  echo -e "${gl_kjlan}15.  ${gl_bai}текстовый редактор vim${gl_kjlan}16.  ${gl_bai}текстовый редактор нано${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}17.  ${gl_bai}система контроля версий git${gl_kjlan}18.  ${gl_bai}помощник по программированию искусственного интеллекта с открытым кодом${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}Заставка Матрица${gl_kjlan}22.  ${gl_bai}Заставка «Идущий поезд»"
	  echo -e "${gl_kjlan}26.  ${gl_bai}Мини-игра тетрис${gl_kjlan}27.  ${gl_bai}Змеиная мини-игра"
	  echo -e "${gl_kjlan}28.  ${gl_bai}Мини-игра «Космические захватчики»"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}31.  ${gl_bai}Установить все${gl_kjlan}32.  ${gl_bai}Установить все (кроме заставок и игр)${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}Удалить все"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}41.  ${gl_bai}Установить указанные инструменты${gl_kjlan}42.  ${gl_bai}Удалить указанный инструмент"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  install curl
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  curl --help
			  send_stats "Установить локон"
			  ;;
		  2)
			  clear
			  install wget
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  wget --help
			  send_stats "Установить wget"
			  ;;
			3)
			  clear
			  install sudo
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  sudo --help
			  send_stats "установить судо"
			  ;;
			4)
			  clear
			  install socat
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  socat -h
			  send_stats "Установить сокат"
			  ;;
			5)
			  clear
			  install htop
			  clear
			  htop
			  send_stats "Установить хтоп"
			  ;;
			6)
			  clear
			  install iftop
			  clear
			  iftop
			  send_stats "Установить ифтоп"
			  ;;
			7)
			  clear
			  install unzip
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  unzip
			  send_stats "установитьразархивировать"
			  ;;
			8)
			  clear
			  install tar
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  tar --help
			  send_stats "Установить tar"
			  ;;
			9)
			  clear
			  install tmux
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  tmux --help
			  send_stats "Установить tmux"
			  ;;
			10)
			  clear
			  install ffmpeg
			  clear
			  echo "Инструмент установлен и используется следующим образом:"
			  ffmpeg --help
			  send_stats "Установить ffmpeg"
			  ;;

			11)
			  clear
			  install btop
			  clear
			  btop
			  send_stats "Установить бтоп"
			  ;;
			12)
			  clear
			  install ranger
			  cd /
			  clear
			  ranger
			  cd ~
			  send_stats "Установить рейнджер"
			  ;;
			13)
			  clear
			  install ncdu
			  cd /
			  clear
			  ncdu
			  cd ~
			  send_stats "Установить нкду"
			  ;;
			14)
			  clear
			  install fzf
			  cd /
			  clear
			  fzf
			  cd ~
			  send_stats "Установить ФЗФ"
			  ;;
			15)
			  clear
			  install vim
			  cd /
			  clear
			  vim -h
			  cd ~
			  send_stats "Установить ВИМ"
			  ;;
			16)
			  clear
			  install nano
			  cd /
			  clear
			  nano -h
			  cd ~
			  send_stats "Установить нано"
			  ;;


			17)
			  clear
			  install git
			  cd /
			  clear
			  git --help
			  cd ~
			  send_stats "Установить git"
			  ;;

			18)
			  clear
			  cd ~
			  curl -fsSL https://opencode.ai/install | bash
			  source ~/.bashrc
			  source ~/.profile
			  opencode
			  send_stats "Установить открытый код"
			  ;;


			21)
			  clear
			  install cmatrix
			  clear
			  cmatrix
			  send_stats "Установить cmatrix"
			  ;;
			22)
			  clear
			  install sl
			  clear
			  sl
			  send_stats "Установить сл"
			  ;;
			26)
			  clear
			  install bastet
			  clear
			  bastet
			  send_stats "Установить бастет"
			  ;;
			27)
			  clear
			  install nsnake
			  clear
			  nsnake
			  send_stats "Установить нснейк"
			  ;;

			28)
			  clear
			  install ninvaders
			  clear
			  ninvaders
			  send_stats "Установить нинвейдеров"
			  ;;

		  31)
			  clear
			  send_stats "Установить все"
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  ;;

		  32)
			  clear
			  send_stats "Установить все (кроме игр и заставок)"
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git
			  ;;


		  33)
			  clear
			  send_stats "Удалить все"
			  remove htop iftop tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  opencode uninstall
			  rm -rf ~/.opencode
			  ;;

		  41)
			  clear
			  read -e -p "Введите имя установленного инструмента (wget curl sudo htop):" installname
			  install $installname
			  send_stats "Установить указанное программное обеспечение"
			  ;;
		  42)
			  clear
			  read -e -p "Введите имя удаленного инструмента (htop ufw tmux cmatrix):" removename
			  remove $removename
			  send_stats "Удалить указанное программное обеспечение"
			  ;;

		  0)
			  kejilion
			  ;;

		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end
  done




}


linux_bbr() {
	clear
	send_stats "управление ббр"
	if [ -f "/etc/alpine-release" ]; then
		while true; do
			  clear
			  local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
			  local queue_algorithm=$(sysctl -n net.core.default_qdisc)
			  echo "Текущий алгоритм блокировки TCP:$congestion_algorithm $queue_algorithm"

			  echo ""
			  echo "Управление ББР"
			  echo "------------------------"
			  echo "1. Включите BBRv3 2. Выключите BBRv3 (он перезагрузится)"
			  echo "------------------------"
			  echo "0. Вернуться в предыдущее меню"
			  echo "------------------------"
			  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

			  case $sub_choice in
				  1)
					bbr_on
					send_stats "Alpine открывает BBR3"
					  ;;
				  2)
					sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
					sysctl -p
					server_reboot
					  ;;
				  *)
					  break  # 跳出循环，退出菜单
					  ;;

			  esac
		done
	else
		install wget
		wget --no-check-certificate -O tcpx.sh ${gh_proxy}raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh
		chmod +x tcpx.sh
		./tcpx.sh
	fi


}





docker_ssh_migration() {

	is_compose_container() {
		local container=$1
		docker inspect "$container" | jq -e '.[0].Config.Labels["com.docker.compose.project"]' >/dev/null 2>&1
	}

	list_backups() {
		local BACKUP_ROOT="/tmp"
		echo -e "${gl_kjlan}Текущий список резервных копий:${gl_bai}"
		ls -1dt ${BACKUP_ROOT}/docker_backup_* 2>/dev/null || echo "Нет резервной копии"
	}



	# ----------------------------
	# резервное копирование
	# ----------------------------
	backup_docker() {
		send_stats "Резервное копирование докера"

		echo -e "${gl_kjlan}Резервное копирование контейнеров Docker...${gl_bai}"
		docker ps --format '{{.Names}}'
		read -e -p  "Введите имя контейнера, для которого требуется создать резервную копию (разделите несколько пробелов и нажмите Enter, чтобы создать резервную копию всех работающих контейнеров):" containers

		install tar jq gzip
		install_docker

		local BACKUP_ROOT="/tmp"
		local DATE_STR=$(date +%Y%m%d_%H%M%S)
		local TARGET_CONTAINERS=()
		if [ -z "$containers" ]; then
			mapfile -t TARGET_CONTAINERS < <(docker ps --format '{{.Names}}')
		else
			read -ra TARGET_CONTAINERS <<< "$containers"
		fi
		[[ ${#TARGET_CONTAINERS[@]} -eq 0 ]] && { echo -e "${gl_hong}Контейнер не найден${gl_bai}"; return; }

		local BACKUP_DIR="${BACKUP_ROOT}/docker_backup_${DATE_STR}"
		mkdir -p "$BACKUP_DIR"

		local RESTORE_SCRIPT="${BACKUP_DIR}/docker_restore.sh"
		echo "#!/bin/bash" > "$RESTORE_SCRIPT"
		echo "set -e" >> "$RESTORE_SCRIPT"
		echo "# Автоматически созданный сценарий восстановления" >> "$RESTORE_SCRIPT"

		# Запишите путь к упакованному проекту Compose, чтобы избежать повторной упаковки.
		declare -A PACKED_COMPOSE_PATHS=()

		for c in "${TARGET_CONTAINERS[@]}"; do
			echo -e "${gl_lv}Резервный контейнер:$c${gl_bai}"
			local inspect_file="${BACKUP_DIR}/${c}_inspect.json"
			docker inspect "$c" > "$inspect_file"

			if is_compose_container "$c"; then
				echo -e "${gl_kjlan}обнаружен$cпредставляет собой контейнер для создания докеров${gl_bai}"
				local project_dir=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project.working_dir"] // empty')
				local project_name=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project"] // empty')

				if [ -z "$project_dir" ]; then
					read -e -p  "Каталог создания не обнаружен, введите путь вручную:" project_dir
				fi

				# Если проект Compose уже упакован, пропустите
				if [[ -n "${PACKED_COMPOSE_PATHS[$project_dir]}" ]]; then
					echo -e "${gl_huang}Создать проект [$project_name] Резервная копия уже создана, пропустите повторную упаковку...${gl_bai}"
					continue
				fi

				if [ -f "$project_dir/docker-compose.yml" ]; then
					echo "compose" > "${BACKUP_DIR}/backup_type_${project_name}"
					echo "$project_dir" > "${BACKUP_DIR}/compose_path_${project_name}.txt"
					tar -czf "${BACKUP_DIR}/compose_project_${project_name}.tar.gz" -C "$project_dir" .
					echo "# восстановление docker-compose:$project_name" >> "$RESTORE_SCRIPT"
					echo "cd \"$project_dir\" && docker compose up -d" >> "$RESTORE_SCRIPT"
					PACKED_COMPOSE_PATHS["$project_dir"]=1
					echo -e "${gl_lv}Создать проект [$project_name] В упаковке:${project_dir}${gl_bai}"
				else
					echo -e "${gl_hong}docker-compose.yml не найден, этот контейнер пропускается...${gl_bai}"
				fi
			else
				# Обычный том резервной копии контейнера
				local VOL_PATHS
				VOL_PATHS=$(docker inspect "$c" --format '{{range .Mounts}}{{.Source}} {{end}}')
				for path in $VOL_PATHS; do
					echo "Объем упаковки:$path"
					tar -czpf "${BACKUP_DIR}/${c}_$(basename $path).tar.gz" -C / "$(echo $path | sed 's/^\///')"
				done

				# порт
				local PORT_ARGS=""
				mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[] | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$inspect_file" 2>/dev/null)
				for p in "${PORTS[@]}"; do PORT_ARGS+="-p $p "; done

				# переменные среды
				local ENV_VARS=""
				mapfile -t ENVS < <(jq -r '.[0].Config.Env[] | @sh' "$inspect_file")
				for e in "${ENVS[@]}"; do ENV_VARS+="-e $e "; done

				# сопоставление томов
				local VOL_ARGS=""
				for path in $VOL_PATHS; do VOL_ARGS+="-v $path:$path "; done

				# Зеркало
				local IMAGE
				IMAGE=$(jq -r '.[0].Config.Image' "$inspect_file")

				echo -e "\n# Восстановить контейнер:$c" >> "$RESTORE_SCRIPT"
				echo "docker run -d --name $c $PORT_ARGS $VOL_ARGS $ENV_VARS $IMAGE" >> "$RESTORE_SCRIPT"
			fi
		done


		# Создайте резервную копию всех файлов в /home/docker (за исключением подкаталогов).
		if [ -d "/home/docker" ]; then
			echo -e "${gl_kjlan}Резервное копирование файлов в /home/docker...${gl_bai}"
			find /home/docker -maxdepth 1 -type f | tar -czf "${BACKUP_DIR}/home_docker_files.tar.gz" -T -
			echo -e "${gl_lv}Файлы в /home/docker были упакованы в:${BACKUP_DIR}/home_docker_files.tar.gz${gl_bai}"
		fi

		chmod +x "$RESTORE_SCRIPT"
		echo -e "${gl_lv}Резервное копирование завершено:${BACKUP_DIR}${gl_bai}"
		echo -e "${gl_lv}Доступные сценарии восстановления:${RESTORE_SCRIPT}${gl_bai}"


	}

	# ----------------------------
	# снижение
	# ----------------------------
	restore_docker() {

		send_stats "Восстановление докера"
		read -e -p  "Пожалуйста, введите каталог резервной копии для восстановления:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}Каталог резервных копий не существует${gl_bai}"; return; }

		echo -e "${gl_kjlan}Начинаем операцию восстановления...${gl_bai}"

		install tar jq gzip
		install_docker

		# --------- Установите приоритет восстановления проектов Compose ---------
		for f in "$BACKUP_DIR"/backup_type_*; do
			[[ ! -f "$f" ]] && continue
			if grep -q "compose" "$f"; then
				project_name=$(basename "$f" | sed 's/backup_type_//')
				path_file="$BACKUP_DIR/compose_path_${project_name}.txt"
				[[ -f "$path_file" ]] && original_path=$(cat "$path_file") || original_path=""
				[[ -z "$original_path" ]] && read -e -p  "Исходный путь не найден, введите путь к каталогу восстановления:" original_path

				# Проверьте, запущен ли уже контейнер проекта создания
				running_count=$(docker ps --filter "label=com.docker.compose.project=$project_name" --format '{{.Names}}' | wc -l)
				if [[ "$running_count" -gt 0 ]]; then
					echo -e "${gl_huang}Создать проект [$project_name] Контейнеры уже запущены, пропустите восстановление...${gl_bai}"
					continue
				fi

				read -e -p  "Подтвердите восстановление проекта Compose [$project_name] к пути [$original_path] ? (y/n): " confirm
				[[ "$confirm" != "y" ]] && read -e -p  "Введите новый путь восстановления:" original_path

				mkdir -p "$original_path"
				tar -xzf "$BACKUP_DIR/compose_project_${project_name}.tar.gz" -C "$original_path"
				echo -e "${gl_lv}Создать проект [$project_name] был извлечен в:$original_path${gl_bai}"

				cd "$original_path" || return
				docker compose down || true
				docker compose up -d
				echo -e "${gl_lv}Создать проект [$project_name] Восстановление завершено!${gl_bai}"
			fi
		done

		# --------- Продолжаем восстанавливать нормальные контейнеры ---------
		echo -e "${gl_kjlan}Проверьте и восстановите обычные контейнеры Docker...${gl_bai}"
		local has_container=false
		for json in "$BACKUP_DIR"/*_inspect.json; do
			[[ ! -f "$json" ]] && continue
			has_container=true
			container=$(basename "$json" | sed 's/_inspect.json//')
			echo -e "${gl_lv}Контейнер для обработки:$container${gl_bai}"

			# Проверьте, существует ли контейнер и запущен ли он
			if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${gl_huang}контейнер [$container] уже запущен, пропускаю восстановление...${gl_bai}"
				continue
			fi

			IMAGE=$(jq -r '.[0].Config.Image' "$json")
			[[ -z "$IMAGE" || "$IMAGE" == "null" ]] && { echo -e "${gl_hong}Информация о зеркале не найдена, пропустите:$container${gl_bai}"; continue; }

			# сопоставление портов
			PORT_ARGS=""
			mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[]? | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$json")
			for p in "${PORTS[@]}"; do
				[[ -n "$p" ]] && PORT_ARGS="$PORT_ARGS -p $p"
			done

			# переменные среды
			ENV_ARGS=""
			mapfile -t ENVS < <(jq -r '.[0].Config.Env[]' "$json")
			for e in "${ENVS[@]}"; do
				ENV_ARGS="$ENV_ARGS -e \"$e\""
			done

			# Сопоставление томов + восстановление данных томов
			VOL_ARGS=""
			mapfile -t VOLS < <(jq -r '.[0].Mounts[] | "\(.Source):\(.Destination)"' "$json")
			for v in "${VOLS[@]}"; do
				VOL_SRC=$(echo "$v" | cut -d':' -f1)
				VOL_DST=$(echo "$v" | cut -d':' -f2)
				mkdir -p "$VOL_SRC"
				VOL_ARGS="$VOL_ARGS -v $VOL_SRC:$VOL_DST"

				VOL_FILE="$BACKUP_DIR/${container}_$(basename $VOL_SRC).tar.gz"
				if [[ -f "$VOL_FILE" ]]; then
					echo "Восстановить данные тома:$VOL_SRC"
					tar -xzf "$VOL_FILE" -C /
				fi
			done

			# Удалить существующие, но не запущенные контейнеры
			if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${gl_huang}контейнер [$container] существует, но не запущен, удалите старый контейнер...${gl_bai}"
				docker rm -f "$container"
			fi

			# Запустить контейнер
			echo "Выполните команду восстановления: docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
			eval "docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
		done

		[[ "$has_container" == false ]] && echo -e "${gl_huang}Не найдена резервная информация для общих контейнеров.${gl_bai}"

		# Восстановить файлы в /home/docker
		if [ -f "$BACKUP_DIR/home_docker_files.tar.gz" ]; then
			echo -e "${gl_kjlan}Восстановление файлов в /home/docker...${gl_bai}"
			mkdir -p /home/docker
			tar -xzf "$BACKUP_DIR/home_docker_files.tar.gz" -C /
			echo -e "${gl_lv}Файлы в /home/docker восстановлены.${gl_bai}"
		else
			echo -e "${gl_huang}Резервная копия файла в /home/docker не найдена, пропуск...${gl_bai}"
		fi


	}


	# ----------------------------
	# мигрировать
	# ----------------------------
	migrate_docker() {
		send_stats "Докер-миграция"
		install jq
		read -e -p  "Пожалуйста, введите каталог резервной копии для переноса:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}Каталог резервных копий не существует${gl_bai}"; return; }

		read -e -p  "IP целевого сервера:" TARGET_IP
		read -e -p  "Имя пользователя SSH целевого сервера:" TARGET_USER
		read -e -p "SSH-порт целевого сервера [по умолчанию 22]:" TARGET_PORT
		local TARGET_PORT=${TARGET_PORT:-22}

		local LATEST_TAR="$BACKUP_DIR"

		echo -e "${gl_huang}Перенос резервной копии...${gl_bai}"
		if [[ -z "$TARGET_PASS" ]]; then
			# Войти с помощью ключа
			scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no -r "$LATEST_TAR" "$TARGET_USER@$TARGET_IP:/tmp/"
		fi

	}

	# ----------------------------
	# Удалить резервную копию
	# ----------------------------
	delete_backup() {
		send_stats "Удаление файла резервной копии Docker"
		read -e -p  "Пожалуйста, введите каталог резервной копии, который необходимо удалить:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}Каталог резервных копий не существует${gl_bai}"; return; }
		rm -rf "$BACKUP_DIR"
		echo -e "${gl_lv}Удалена резервная копия:${BACKUP_DIR}${gl_bai}"
	}

	# ----------------------------
	# Главное меню
	# ----------------------------
	main_menu() {
		send_stats "Восстановление резервной копии Docker при миграции"
		while true; do
			clear
			echo "------------------------"
			echo -e "Инструмент резервного копирования, миграции и восстановления Docker"
			echo "------------------------"
			list_backups
			echo -e ""
			echo "------------------------"
			echo -e "1. Резервное копирование проекта Docker."
			echo -e "2. Перенос проекта докера"
			echo -e "3. Восстановить проект докера."
			echo -e "4. Удалите файл резервной копии проекта докеров."
			echo "------------------------"
			echo -e "0. Вернуться в предыдущее меню"
			echo "------------------------"
			read -e -p  "Пожалуйста, выберите:" choice
			case $choice in
				1) backup_docker ;;
				2) migrate_docker ;;
				3) restore_docker ;;
				4) delete_backup ;;
				0) return ;;
				*) echo -e "${gl_hong}Неверный вариант${gl_bai}" ;;
			esac
		break_end
		done
	}

	main_menu
}





linux_docker() {

	while true; do
	  clear
	  # send_stats «управление докером»
	  echo -e "Управление докером"
	  docker_tato
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}Установите и обновите среду Docker.${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}2.   ${gl_bai}Просмотр глобального статуса Docker${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}3.   ${gl_bai}Управление контейнерами Docker${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}4.   ${gl_bai}Управление образами Docker"
	  echo -e "${gl_kjlan}5.   ${gl_bai}Управление сетью Docker"
	  echo -e "${gl_kjlan}6.   ${gl_bai}Управление томами Docker"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}7.   ${gl_bai}Очистите ненужные докер-контейнеры и зеркально отразите тома сетевых данных."
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}8.   ${gl_bai}Изменить источник Docker"
	  echo -e "${gl_kjlan}9.   ${gl_bai}Редактировать файл daemon.json"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}Включить доступ Docker-ipv6"
	  echo -e "${gl_kjlan}12.  ${gl_bai}Отключить доступ Docker-ipv6"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}19.  ${gl_bai}Резервное копирование/перенос/восстановление среды Docker"
	  echo -e "${gl_kjlan}20.  ${gl_bai}Удалите среду Docker"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			clear
			send_stats "Установить среду докера"
			install_add_docker

			  ;;
		  2)
			  clear
			  local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
			  local image_count=$(docker images -q 2>/dev/null | wc -l)
			  local network_count=$(docker network ls -q 2>/dev/null | wc -l)
			  local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

			  send_stats "глобальный статус докера"
			  echo "Докер-версия"
			  docker -v
			  docker compose version

			  echo ""
			  echo -e "Докер-образ:${gl_lv}$image_count${gl_bai} "
			  docker image ls
			  echo ""
			  echo -e "Докер-контейнер:${gl_lv}$container_count${gl_bai}"
			  docker ps -a
			  echo ""
			  echo -e "Тома докера:${gl_lv}$volume_count${gl_bai}"
			  docker volume ls
			  echo ""
			  echo -e "Докер-сеть:${gl_lv}$network_count${gl_bai}"
			  docker network ls
			  echo ""

			  ;;
		  3)
			  docker_ps
			  ;;
		  4)
			  docker_image
			  ;;

		  5)
			  while true; do
				  clear
				  send_stats "Управление сетью Docker"
				  echo "Список сетей Docker"
				  echo "------------------------------------------------------------"
				  docker network ls
				  echo ""

				  echo "------------------------------------------------------------"
				  container_ids=$(docker ps -q)
				  printf "%-25s %-25s %-25s\n" "Имя контейнера" "имя сети" "IP-адрес"

				  for container_id in $container_ids; do
					  local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

					  local container_name=$(echo "$container_info" | awk '{print $1}')
					  local network_info=$(echo "$container_info" | cut -d' ' -f2-)

					  while IFS= read -r line; do
						  local network_name=$(echo "$line" | awk '{print $1}')
						  local ip_address=$(echo "$line" | awk '{print $2}')

						  printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
					  done <<< "$network_info"
				  done

				  echo ""
				  echo "сетевые операции"
				  echo "------------------------"
				  echo "1. Создайте сеть"
				  echo "2. Присоединяйтесь к сети"
				  echo "3. Выйти из сети"
				  echo "4. Удалить сеть"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
						  send_stats "Создать сеть"
						  read -e -p "Установите новое имя сети:" dockernetwork
						  docker network create $dockernetwork
						  ;;
					  2)
						  send_stats "Присоединяйтесь к сети"
						  read -e -p "Добавьте имя сети:" dockernetwork
						  read -e -p "Какие контейнеры присоединяются к сети (пожалуйста, разделяйте несколько имен контейнеров пробелами):" dockernames

						  for dockername in $dockernames; do
							  docker network connect $dockernetwork $dockername
						  done
						  ;;
					  3)
						  send_stats "Присоединяйтесь к сети"
						  read -e -p "Выходное имя сети:" dockernetwork
						  read -e -p "Эти контейнеры выходят из сети (пожалуйста, разделяйте несколько имен контейнеров пробелами):" dockernames

						  for dockername in $dockernames; do
							  docker network disconnect $dockernetwork $dockername
						  done

						  ;;

					  4)
						  send_stats "удалить сеть"
						  read -e -p "Пожалуйста, введите имя сети, которую необходимо удалить:" dockernetwork
						  docker network rm $dockernetwork
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;

		  6)
			  while true; do
				  clear
				  send_stats "Управление томами Docker"
				  echo "Список томов Docker"
				  docker volume ls
				  echo ""
				  echo "Операции с объемами"
				  echo "------------------------"
				  echo "1. Создайте новый том."
				  echo "2. Удалить указанный том"
				  echo "3. Удалить все тома"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
						  send_stats "Создать новый том"
						  read -e -p "Установите новое имя тома:" dockerjuan
						  docker volume create $dockerjuan

						  ;;
					  2)
						  read -e -p "Введите имя удаляемого тома (разделяйте несколько имен томов пробелами):" dockerjuans

						  for dockerjuan in $dockerjuans; do
							  docker volume rm $dockerjuan
						  done

						  ;;

					   3)
						  send_stats "Удалить все тома"
						  read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有未使用的卷吗？(Y/N): ")" choice
						  case "$choice" in
							[Yy])
							  docker volume prune -f
							  ;;
							[Nn])
							  ;;
							*)
							  echo "Неверный выбор, введите Y или N."
							  ;;
						  esac
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;
		  7)
			  clear
			  send_stats "Очистка докера"
			  read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}将清理无用的镜像容器网络，包括停止的容器，确定清理吗？(Y/N): ")" choice
			  case "$choice" in
				[Yy])
				  docker system prune -af --volumes
				  ;;
				[Nn])
				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac
			  ;;
		  8)
			  clear
			  send_stats "Исходный код докера"
			  bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
			  ;;

		  9)
			  clear
			  install nano
			  mkdir -p /etc/docker && nano /etc/docker/daemon.json
			  restart docker
			  ;;




		  11)
			  clear
			  send_stats "Докер v6 включен"
			  docker_ipv6_on
			  ;;

		  12)
			  clear
			  send_stats "Docker v6 Закрыть"
			  docker_ipv6_off
			  ;;

		  19)
			  docker_ssh_migration
			  ;;


		  20)
			  clear
			  send_stats "Удаление докера"
			  read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定卸载docker环境吗？(Y/N): ")" choice
			  case "$choice" in
				[Yy])
				  docker ps -a -q | xargs -r docker rm -f && docker images -q | xargs -r docker rmi && docker network prune -f && docker volume prune -f
				  remove docker docker-compose docker-ce docker-ce-cli containerd.io
				  rm -f /etc/docker/daemon.json
				  hash -r
				  ;;
				[Nn])
				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac
			  ;;

		  0)
			  kejilion
			  ;;
		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end


	done


}



linux_test() {

	while true; do
	  clear
	  # send_stats "Коллекция тестовых сценариев"
	  echo -e "Коллекция тестовых сценариев"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}Определение IP и статуса разблокировки"
	  echo -e "${gl_kjlan}1.   ${gl_bai}Определение статуса разблокировки ChatGPT"
	  echo -e "${gl_kjlan}2.   ${gl_bai}Тест разблокировки потокового мультимедиа в регионе"
	  echo -e "${gl_kjlan}3.   ${gl_bai}дау, обнаружение разблокировки потокового мультимедиа"
	  echo -e "${gl_kjlan}4.   ${gl_bai}xykt скрипт проверки качества IP${gl_huang}★${gl_bai}"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}Тест скорости сетевой линии"
	  echo -e "${gl_kjlan}11.  ${gl_bai}тест маршрутизации с задержкой транзитного соединения в сети besttrace Three"
	  echo -e "${gl_kjlan}12.  ${gl_bai}mtr_trace тест транспортной линии тройной сети"
	  echo -e "${gl_kjlan}13.  ${gl_bai}Тест тройной скорости сети Superspeed"
	  echo -e "${gl_kjlan}14.  ${gl_bai}Сценарий тестирования быстрого обратного соединения nxtrace"
	  echo -e "${gl_kjlan}15.  ${gl_bai}nxtrace указывает сценарий тестирования обратного соединения IP"
	  echo -e "${gl_kjlan}16.  ${gl_bai}ludashi2020 тест трех сетевых линий"
	  echo -e "${gl_kjlan}17.  ${gl_bai}Сценарий многофункционального теста скорости i-abc"
	  echo -e "${gl_kjlan}18.  ${gl_bai}Скрипт проверки качества сети NetQuality${gl_huang}★${gl_bai}"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}Тестирование производительности оборудования"
	  echo -e "${gl_kjlan}21.  ${gl_bai}тест производительности yabs"
	  echo -e "${gl_kjlan}22.  ${gl_bai}Сценарий теста производительности процессора icu/gb5"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}Комплексное тестирование"
	  echo -e "${gl_kjlan}31.  ${gl_bai}стендовые испытания производительности"
	  echo -e "${gl_kjlan}32.  ${gl_bai}Оценка монстра Spiritysdx fusion${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}Оценка монстра Nodequality Fusion${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  send_stats "Определение статуса разблокировки ChatGPT"
			  bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
			  ;;
		  2)
			  clear
			  send_stats "Тест разблокировки потокового мультимедиа в регионе"
			  bash <(curl -L -s check.unlock.media)
			  ;;
		  3)
			  clear
			  send_stats "дау, обнаружение разблокировки потокового мультимедиа"
			  install wget
			  wget -qO- ${gh_proxy}github.com/yeahwu/check/raw/main/check.sh | bash
			  ;;
		  4)
			  clear
			  send_stats "скрипт проверки качества xykt_IP"
			  bash <(curl -Ls IP.Check.Place)
			  ;;


		  11)
			  clear
			  send_stats "тест маршрутизации с задержкой транзитного соединения в тройной сети besttrace"
			  install wget
			  wget -qO- git.io/besttrace | bash
			  ;;
		  12)
			  clear
			  send_stats "mtr_trace тест транспортной линии тройной сети"
			  curl ${gh_proxy}raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
			  ;;
		  13)
			  clear
			  send_stats "Тест тройной скорости сети Superspeed"
			  bash <(curl -Lso- https://git.io/superspeed_uxh)
			  ;;
		  14)
			  clear
			  send_stats "Сценарий тестирования быстрого обратного соединения nxtrace"
			  curl nxtrace.org/nt |bash
			  nexttrace --fast-trace --tcp
			  ;;
		  15)
			  clear
			  send_stats "nxtrace указывает сценарий тестирования обратного соединения IP"
			  echo "Список эталонных IP-адресов"
			  echo "------------------------"
			  echo "Пекин Телеком: 219.141.136.12"
			  echo "Пекин Юником: 202.106.50.1"
			  echo "Пекин Мобильный: 221.179.155.161"
			  echo "Шанхай Телеком: 202.96.209.133"
			  echo "Шанхай Юником: 210.22.97.1"
			  echo "Шанхай мобильный: 211.136.112.200"
			  echo "Гуанчжоу Телеком: 58.60.188.222"
			  echo "Гуанчжоу China Unicom: 210.21.196.6"
			  echo "Гуанчжоу Мобильный: 120.196.165.24"
			  echo "Чэнду Телеком: 61.139.2.69"
			  echo "Чэнду Чайна Юником: 119.6.6.6"
			  echo "Чэнду мобильный: 211.137.96.205"
			  echo "Хунань Телеком: 36.111.200.100"
			  echo "Хунань Юником: 42.48.16.100"
			  echo "Хунань мобильный: 39.134.254.6"
			  echo "------------------------"

			  read -e -p "Введите конкретный IP:" testip
			  curl nxtrace.org/nt |bash
			  nexttrace $testip
			  ;;

		  16)
			  clear
			  send_stats "ludashi2020 тест трех сетевых линий"
			  curl ${gh_proxy}raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
			  ;;

		  17)
			  clear
			  send_stats "i-abc многофункциональный сценарий проверки скорости"
			  bash <(curl -sL ${gh_proxy}raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)
			  ;;

		  18)
			  clear
			  send_stats "Скрипт проверки качества сети"
			  bash <(curl -sL Net.Check.Place)
			  ;;

		  21)
			  clear
			  send_stats "тест производительности yabs"
			  check_swap
			  curl -sL yabs.sh | bash -s -- -i -5
			  ;;
		  22)
			  clear
			  send_stats "Сценарий теста производительности процессора icu/gb5"
			  check_swap
			  bash <(curl -sL bash.icu/gb5)
			  ;;

		  31)
			  clear
			  send_stats "стендовые испытания производительности"
			  curl -Lso- bench.sh | bash
			  ;;
		  32)
			  send_stats "Обзор Spiritysdx Fusion Monster"
			  clear
			  curl -L ${gh_proxy}gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
			  ;;

		  33)
			  send_stats "Оценка монстра Nodequality Fusion"
			  clear
			  bash <(curl -sL https://run.NodeQuality.com)
			  ;;



		  0)
			  kejilion

			  ;;
		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end

	done


}


linux_Oracle() {


	 while true; do
	  clear
	  send_stats "Коллекция сценариев Oracle Cloud"
	  echo -e "Коллекция сценариев Oracle Cloud"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}Установить активный сценарий простоя машины"
	  echo -e "${gl_kjlan}2.   ${gl_bai}Удалить активные скрипты с простаивающих машин"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}3.   ${gl_bai}DD скрипт переустановки системы"
	  echo -e "${gl_kjlan}4.   ${gl_bai}Сценарий запуска детектива R"
	  echo -e "${gl_kjlan}5.   ${gl_bai}Включить режим входа в систему с паролем ROOT"
	  echo -e "${gl_kjlan}6.   ${gl_bai}Инструмент восстановления IPV6"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  echo "Активный сценарий: загрузка процессора 10–20 %, загрузка памяти 20 %."
			  read -e -p "Вы уверены, что хотите установить его? (Да/Нет):" choice
			  case "$choice" in
				[Yy])

				  install_docker

				  # Установить значение по умолчанию
				  local DEFAULT_CPU_CORE=1
				  local DEFAULT_CPU_UTIL="10-20"
				  local DEFAULT_MEM_UTIL=20
				  local DEFAULT_SPEEDTEST_INTERVAL=120

				  # Предлагает пользователю ввести количество ядер ЦП и процент занятости. Если пользователь нажмет Enter, будет использовано значение по умолчанию.
				  read -e -p "Пожалуйста, введите количество ядер ЦП [По умолчанию:$DEFAULT_CPU_CORE]: " cpu_core
				  local cpu_core=${cpu_core:-$DEFAULT_CPU_CORE}

				  read -e -p "Введите процент использования ЦП (например, 10–20) [По умолчанию:$DEFAULT_CPU_UTIL]: " cpu_util
				  local cpu_util=${cpu_util:-$DEFAULT_CPU_UTIL}

				  read -e -p "Пожалуйста, введите процент использования памяти [По умолчанию:$DEFAULT_MEM_UTIL]: " mem_util
				  local mem_util=${mem_util:-$DEFAULT_MEM_UTIL}

				  read -e -p "Введите время интервала проверки скорости (в секундах) [По умолчанию:$DEFAULT_SPEEDTEST_INTERVAL]: " speedtest_interval
				  local speedtest_interval=${speedtest_interval:-$DEFAULT_SPEEDTEST_INTERVAL}

				  # Запустить Docker-контейнер
				  docker run -d --name=lookbusy --restart=always \
					  -e TZ=Asia/Shanghai \
					  -e CPU_UTIL="$cpu_util" \
					  -e CPU_CORE="$cpu_core" \
					  -e MEM_UTIL="$mem_util" \
					  -e SPEEDTEST_INTERVAL="$speedtest_interval" \
					  fogforest/lookbusy
				  send_stats "Активный сценарий установки Oracle Cloud"

				  ;;
				[Nn])

				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac
			  ;;
		  2)
			  clear
			  docker rm -f lookbusy
			  docker rmi fogforest/lookbusy
			  send_stats "Активный сценарий удаления Oracle Cloud"
			  ;;

		  3)
		  clear
		  echo "Переустановите систему"
		  echo "--------------------------------"
		  echo -e "${gl_hong}Уведомление:${gl_bai}Переустановка может привести к потере соединения, поэтому будьте осторожны, если вы обеспокоены. Ожидается, что переустановка займет 15 минут. Пожалуйста, заранее сделайте резервную копию данных."
		  read -e -p "Вы уверены, что хотите продолжить? (Да/Нет):" choice

		  case "$choice" in
			[Yy])
			  while true; do
				read -e -p "Пожалуйста, выберите систему, которую вы хотите переустановить: 1. Debian12 | 2. Ubuntu20.04:" sys_choice

				case "$sys_choice" in
				  1)
					local xitong="-d 12"
					break  # 结束循环
					;;
				  2)
					local xitong="-u 20.04"
					break  # 结束循环
					;;
				  *)
					echo "Неверный выбор, пожалуйста, введите еще раз."
					;;
				esac
			  done

			  read -e -p "Пожалуйста, введите свой пароль после переустановки:" vpspasswd
			  install wget
			  bash <(wget --no-check-certificate -qO- "${gh_proxy}raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh") $xitong -v 64 -p $vpspasswd -port 22
			  send_stats "Скрипт переустановки системы Oracle Cloud"
			  ;;
			[Nn])
			  echo "Отменено"
			  ;;
			*)
			  echo "Неверный выбор, введите Y или N."
			  ;;
		  esac
			  ;;

		  4)
			  clear
			  send_stats "Сценарий запуска детектива R"
			  bash <(wget -qO- ${gh_proxy}github.com/Yohann0617/oci-helper/releases/latest/download/sh_oci-helper_install.sh)
			  ;;
		  5)
			  clear
			  add_sshpasswd
			  ;;
		  6)
			  clear
			  bash <(curl -L -s jhb.ovh/jb/v6.sh)
			  echo "Эту функцию предоставил jhb, спасибо ему!"
			  send_stats "ремонт ipv6"
			  ;;
		  0)
			  kejilion

			  ;;
		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end

	done



}





docker_tato() {

	local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
	local image_count=$(docker images -q 2>/dev/null | wc -l)
	local network_count=$(docker network ls -q 2>/dev/null | wc -l)
	local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

	if command -v docker &> /dev/null; then
		echo -e "${gl_kjlan}------------------------"
		echo -e "${gl_lv}Среда установлена.${gl_bai}контейнер:${gl_lv}$container_count${gl_bai}Зеркало:${gl_lv}$image_count${gl_bai}сеть:${gl_lv}$network_count${gl_bai}рулон:${gl_lv}$volume_count${gl_bai}"
	fi
}



ldnmp_tato() {
local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
local output="${gl_lv}${cert_count}${gl_bai}"

local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml 2>/dev/null | tr -d '[:space:]')
if [ -n "$dbrootpasswd" ]; then
	local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
fi

local db_output="${gl_lv}${db_count}${gl_bai}"


if command -v docker &>/dev/null; then
	if docker ps --filter "name=nginx" --filter "status=running" | grep -q nginx; then
		echo -e "${gl_huang}------------------------"
		echo -e "${gl_lv}Среда установлена${gl_bai}Сайт:$outputбаза данных:$db_output"
	fi
fi

}


fix_phpfpm_conf() {
	local container_name=$1
	docker exec "$container_name" sh -c "mkdir -p /run/$container_name && chmod 777 /run/$container_name"
	docker exec "$container_name" sh -c "sed -i '1i [global]\\ndaemonize = no' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "sed -i '/^listen =/d' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "echo -e '\nlisten = /run/$container_name/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data\nlisten.mode = 0777' >> /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "rm -f /usr/local/etc/php-fpm.d/zz-docker.conf"

	find /home/web/conf.d/ -type f -name "*.conf" -exec sed -i "s#fastcgi_pass ${container_name}:9000;#fastcgi_pass unix:/run/${container_name}/php-fpm.sock;#g" {} \;

}






linux_ldnmp() {
  while true; do

	clear
	# send_stats "Создание веб-сайта LDNMP"
	echo -e "${gl_huang}Создание сайта ЛДНМП"
	ldnmp_tato
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}1.   ${gl_bai}Установите среду LDNMP${gl_huang}★${gl_bai}                   ${gl_huang}2.   ${gl_bai}Установить WordPress${gl_huang}★${gl_bai}"
	echo -e "${gl_huang}3.   ${gl_bai}Установить Discuz Forum${gl_huang}4.   ${gl_bai}Установите Kedao Cloud Desktop"
	echo -e "${gl_huang}5.   ${gl_bai}Установите Apple CMS Movie and TV Station${gl_huang}6.   ${gl_bai}Установите сеть цифровых карт Unicorn"
	echo -e "${gl_huang}7.   ${gl_bai}Установить сайт форума Flarum${gl_huang}8.   ${gl_bai}Установить облегченный блог-сайт typecho"
	echo -e "${gl_huang}9.   ${gl_bai}Установите платформу обмена ссылками LinkStack.${gl_huang}20.  ${gl_bai}Пользовательский динамический сайт"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}21.  ${gl_bai}Устанавливайте только nginx${gl_huang}★${gl_bai}                     ${gl_huang}22.  ${gl_bai}перенаправление сайта"
	echo -e "${gl_huang}23.  ${gl_bai}Обратный прокси сайта-IP+порт${gl_huang}★${gl_bai}            ${gl_huang}24.  ${gl_bai}Доменное имя обратного прокси-сервера сайта"
	echo -e "${gl_huang}25.  ${gl_bai}Установите платформу управления паролями Bitwarden${gl_huang}26.  ${gl_bai}Установить сайт блога Halo"
	echo -e "${gl_huang}27.  ${gl_bai}Установите генератор слов для рисования AI${gl_huang}28.  ${gl_bai}Балансировка нагрузки обратного прокси-сервера сайта"
	echo -e "${gl_huang}29.  ${gl_bai}Потоковая четырехуровневая переадресация прокси${gl_huang}30.  ${gl_bai}Пользовательский статический сайт"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}31.  ${gl_bai}Управление данными сайта${gl_huang}★${gl_bai}                    ${gl_huang}32.  ${gl_bai}Резервное копирование данных всего сайта"
	echo -e "${gl_huang}33.  ${gl_bai}Запланированное удаленное резервное копирование${gl_huang}34.  ${gl_bai}Восстановить все данные сайта"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}35.  ${gl_bai}Защита сред LDNMP${gl_huang}36.  ${gl_bai}Оптимизация среды LDNMP"
	echo -e "${gl_huang}37.  ${gl_bai}Обновить среду LDNMP${gl_huang}38.  ${gl_bai}Удалите среду LDNMP"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}0.   ${gl_bai}Вернуться в главное меню"
	echo -e "${gl_huang}------------------------${gl_bai}"
	read -e -p "Пожалуйста, введите ваш выбор:" sub_choice


	case $sub_choice in
	  1)
	  ldnmp_install_status_one
	  ldnmp_install_all
		;;
	  2)
	  ldnmp_wp
		;;

	  3)
	  clear
	  # Дискуз Форум
	  webname="Дискуз Форум"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status


	  install_ssltls
	  certs_status
	  add_db


	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/discuz.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/kejilion/Website_source_code/raw/main/Discuz_X3.5_SC_UTF8_20250901.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Префикс таблицы: Discuz_"


		;;

	  4)
	  clear
	  # Облачный рабочий стол Kedao
	  webname="Облачный рабочий стол Kedao"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status

	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/kdy.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/kalcaddle/kodbox/archive/refs/tags/1.50.02.zip
	  unzip -o latest.zip
	  rm latest.zip
	  mv /home/web/html/$yuming/kodbox* /home/web/html/$yuming/kodbox
	  restart_ldnmp

	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Имя базы данных:$dbname"
	  echo "Хост Redis: Redis"

		;;

	  5)
	  clear
	  # AppleCMS
	  webname="AppleCMS"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/maccms.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  # wget ${gh_proxy}github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && rm maccms10.zip
	  wget ${gh_proxy}github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && mv maccms10-*/* . && rm -r maccms10-* && rm maccms10.zip
	  cd /home/web/html/$yuming/template/ && wget ${gh_proxy}github.com/kejilion/Website_source_code/raw/main/DYXS2.zip && unzip DYXS2.zip && rm /home/web/html/$yuming/template/DYXS2.zip
	  cp /home/web/html/$yuming/template/DYXS2/asset/admin/Dyxs2.php /home/web/html/$yuming/application/admin/controller
	  cp /home/web/html/$yuming/template/DYXS2/asset/admin/dycms.html /home/web/html/$yuming/application/admin/view/system
	  mv /home/web/html/$yuming/admin.php /home/web/html/$yuming/vip.php && wget -O /home/web/html/$yuming/application/extra/maccms.php ${gh_proxy}raw.githubusercontent.com/kejilion/Website_source_code/main/maccms.php

	  restart_ldnmp


	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "Порт базы данных: 3306"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Префикс базы данных: mac_"
	  echo "------------------------"
	  echo "После успешной установки войдите на серверный адрес."
	  echo "https://$yuming/vip.php"

		;;

	  6)
	  clear
	  # Одноногая номерная карточка
	  webname="Одноногая номерная карточка"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db


	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/dujiaoka.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget ${gh_proxy}github.com/assimon/dujiaoka/releases/download/2.0.6/2.0.6-antibody.tar.gz && tar -zxvf 2.0.6-antibody.tar.gz && rm 2.0.6-antibody.tar.gz

	  restart_ldnmp


	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "Порт базы данных: 3306"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo ""
	  echo "адрес Redis: Redis"
	  echo "пароль Redis: не заполнен по умолчанию"
	  echo "порт Redis: 6379"
	  echo ""
	  echo "URL-адрес сайта: https://$yuming"
	  echo "Путь входа в серверную часть: /admin"
	  echo "------------------------"
	  echo "Имя пользователя: admin"
	  echo "Пароль: admin"
	  echo "------------------------"
	  echo "Если при входе в систему в правом верхнем углу появляется красная ошибка error0, используйте следующую команду:"
	  echo "Я также очень зол на то, почему Номерная карта Единорога доставляет столько хлопот и вызывает такие проблемы!"
	  echo "sed -i 's/ADMIN_HTTPS=false/ADMIN_HTTPS=true/g' /home/web/html/$yuming/dujiaoka/.env"

		;;

	  7)
	  clear
	  # фларум форум
	  webname="фларум форум"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/flarum.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf


	  nginx_http_on

	  docker exec php rm -f /usr/local/etc/php/conf.d/optimized_php.ini

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  docker exec php sh -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
	  docker exec php sh -c "php composer-setup.php"
	  docker exec php sh -c "php -r \"unlink('composer-setup.php');\""
	  docker exec php sh -c "mv composer.phar /usr/local/bin/composer"

	  docker exec php composer create-project flarum/flarum /var/www/html/$yuming
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum-lang/chinese-simplified"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum/extension-manager:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/polls"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/sitemap"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/oauth"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/best-answer:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/upload"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/gamification"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/byobu:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require v17development/flarum-seo"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require clarkwinkelmann/flarum-ext-emojionearea"


	  restart_ldnmp


	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Префикс таблицы: flarum_"
	  echo "Информация администратора может быть установлена ​​самостоятельно"

		;;

	  8)
	  clear
	  # typecho
	  webname="typecho"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status




	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/typecho.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/typecho/typecho/releases/latest/download/typecho.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  clear
	  ldnmp_web_on
	  echo "Префикс базы данных: typecho_"
	  echo "Адрес базы данных: mysql"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Имя базы данных:$dbname"

		;;


	  9)
	  clear
	  # LinkStack
	  webname="LinkStack"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status


	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/refs/heads/main/index_php.conf
	  sed -i "s|/var/www/html/yuming.com/|/var/www/html/yuming.com/linkstack|g" /home/web/conf.d/$yuming.conf
	  sed -i "s|yuming.com|$yuming|g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/linkstackorg/linkstack/releases/latest/download/linkstack.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  clear
	  ldnmp_web_on
	  echo "Адрес базы данных: mysql"
	  echo "Порт базы данных: 3306"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
		;;

	  20)
	  clear
	  webname="динамический сайт PHP"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status

	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/index_php.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  clear
	  echo -e "[${gl_huang}1/6${gl_bai}] Загрузите исходный код PHP"
	  echo "-------------"
	  echo "В настоящее время разрешена загрузка только пакетов исходного кода в формате zip. Пожалуйста, поместите пакеты исходного кода в /home/web/html/.${yuming}в каталоге"
	  read -e -p "Вы также можете ввести ссылку для скачивания, чтобы удаленно загрузить пакет исходного кода. Нажмите Enter напрямую, чтобы пропустить удаленную загрузку:" url_download

	  if [ -n "$url_download" ]; then
		  wget "$url_download"
	  fi

	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  clear
	  echo -e "[${gl_huang}2/6${gl_bai}] Путь, по которому находится index.php."
	  echo "-------------"
	  # find "$(realpath .)" -name "index.php" -print
	  find "$(realpath .)" -name "index.php" -print | xargs -I {} dirname {}

	  read -e -p "Пожалуйста, введите путь к index.php, аналогичный (/home/web/html/$yuming/wordpress/）： " index_lujing

	  sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
	  sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf

	  clear
	  echo -e "[${gl_huang}3/6${gl_bai}] Пожалуйста, выберите версию PHP"
	  echo "-------------"
	  read -e -p "1. Последняя версия PHP | 2. php7.4:" pho_v
	  case "$pho_v" in
		1)
		  sed -i "s#php:9000#php:9000#g" /home/web/conf.d/$yuming.conf
		  local PHP_Version="php"
		  ;;
		2)
		  sed -i "s#php:9000#php74:9000#g" /home/web/conf.d/$yuming.conf
		  local PHP_Version="php74"
		  ;;
		*)
		  echo "Неверный выбор, пожалуйста, введите еще раз."
		  ;;
	  esac


	  clear
	  echo -e "[${gl_huang}4/6${gl_bai}] Установить указанное расширение"
	  echo "-------------"
	  echo "Установленные расширения"
	  docker exec php php -m

	  read -e -p "$(echo -e "输入需要安装的扩展名称，如 ${gl_huang}SourceGuardian imap ftp${gl_bai} 等等。直接回车将跳过安装 ： ")" php_extensions
	  if [ -n "$php_extensions" ]; then
		  docker exec $PHP_Version install-php-extensions $php_extensions
	  fi


	  clear
	  echo -e "[${gl_huang}5/6${gl_bai}] Редактировать конфигурацию сайта"
	  echo "-------------"
	  echo "Нажмите любую клавишу, чтобы продолжить. Вы можете детально настроить конфигурацию сайта, например псевдостатический контент."
	  read -n 1 -s -r -p ""
	  install nano
	  nano /home/web/conf.d/$yuming.conf


	  clear
	  echo -e "[${gl_huang}6/6${gl_bai}] Управление базой данных"
	  echo "-------------"
	  read -e -p "1. Я создаю новый сайт. 2. Я создаю старый сайт и имею резервную копию базы данных:" use_db
	  case $use_db in
		  1)
			  echo
			  ;;
		  2)
			  echo "Резервная копия базы данных должна представлять собой сжатый пакет с расширением .gz. Пожалуйста, поместите его в каталог /home/ для поддержки импорта данных резервной копии Pagoda/1panel."
			  read -e -p "Вы также можете ввести ссылку для скачивания, чтобы удаленно загрузить данные резервной копии. Нажмите Enter напрямую, чтобы пропустить удаленную загрузку:" url_download_db

			  cd /home/
			  if [ -n "$url_download_db" ]; then
				  wget "$url_download_db"
			  fi
			  gunzip $(ls -t *.gz | head -n 1)
			  latest_sql=$(ls -t *.sql | head -n 1)
			  dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
			  docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname < "/home/$latest_sql"
			  echo "Импортированные табличные данные базы данных"
			  docker exec -i mysql mysql -u root -p"$dbrootpasswd" -e "USE $dbname; SHOW TABLES;"
			  rm -f *.sql
			  echo "Импорт базы данных завершен."
			  ;;
		  *)
			  echo
			  ;;
	  esac

	  docker exec php rm -f /usr/local/etc/php/conf.d/optimized_php.ini

	  restart_ldnmp
	  ldnmp_web_on
	  prefix="web$(shuf -i 10-99 -n 1)_"
	  echo "Адрес базы данных: mysql"
	  echo "Имя базы данных:$dbname"
	  echo "имя пользователя:$dbuse"
	  echo "пароль:$dbusepasswd"
	  echo "Префикс таблицы:$prefix"
	  echo "Данные для входа администратора задаются самостоятельно."

		;;


	  21)
	  ldnmp_install_status_one
	  nginx_install_all
		;;

	  22)
	  clear
	  webname="перенаправление сайта"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  read -e -p "Пожалуйста, введите имя домена для перенаправления:" reverseproxy
	  nginx_install_status



	  install_ssltls
	  certs_status


	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/rewrite.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
	  sed -i "s/baidu.com/$reverseproxy/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  docker exec nginx nginx -s reload

	  nginx_web_on


		;;

	  23)
	  ldnmp_Proxy
	  find_container_by_host_port "$port"
	  if [ -z "$docker_name" ]; then
		close_port "$port"
		echo "IP+порт заблокирован для доступа к сервису"
	  else
	  	ip_address
		close_port "$port"
		block_container_port "$docker_name" "$ipv4_address"
	  fi

		;;

	  24)
	  clear
	  webname="Обратное прокси-домен"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  echo -e "Формат доменного имени:${gl_huang}google.com${gl_bai}"
	  read -e -p "Пожалуйста, введите доменное имя обратного прокси-сервера:" fandai_yuming
	  nginx_install_status

	  install_ssltls
	  certs_status


	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-domain.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
	  sed -i "s|fandaicom|$fandai_yuming|g" /home/web/conf.d/$yuming.conf


	  nginx_http_on

	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;


	  25)
	  clear
	  webname="Bitwarden"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming

	  docker run -d \
		--name bitwarden \
		--restart=always \
		-p 3280:80 \
		-v /home/web/html/$yuming/bitwarden/data:/data \
		vaultwarden/server

	  duankou=3280
	  ldnmp_Proxy ${yuming} 127.0.0.1 $duankou


		;;

	  26)
	  clear
	  webname="halo"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming

	  docker run -d --name halo --restart=always -p 8010:8090 -v /home/web/html/$yuming/.halo2:/root/.halo2 halohub/halo:2

	  duankou=8010
	  ldnmp_Proxy ${yuming} 127.0.0.1 $duankou

		;;

	  27)
	  clear
	  webname="Генератор слов для рисования AI"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  nginx_install_status


	  install_ssltls
	  certs_status

	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/html.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  wget ${gh_proxy}github.com/kejilion/Website_source_code/raw/refs/heads/main/ai_prompt_generator.zip
	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  docker exec nginx chmod -R nginx:nginx /var/www/html
	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;

	  28)
	  ldnmp_Proxy_backend
		;;


	  29)
	  stream_panel
		;;

	  30)
	  clear
	  webname="статический сайт"
	  send_stats "Установить$webname"
	  echo "Начать развертывание$webname"
	  add_yuming
	  repeat_add_yuming
	  nginx_install_status


	  install_ssltls
	  certs_status

	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/html.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming


	  clear
	  echo -e "[${gl_huang}1/2${gl_bai}] Загрузите статический исходный код"
	  echo "-------------"
	  echo "В настоящее время разрешена загрузка только пакетов исходного кода в формате zip. Пожалуйста, поместите пакеты исходного кода в /home/web/html/.${yuming}в каталоге"
	  read -e -p "Вы также можете ввести ссылку для скачивания, чтобы удаленно загрузить пакет исходного кода. Нажмите Enter напрямую, чтобы пропустить удаленную загрузку:" url_download

	  if [ -n "$url_download" ]; then
		  wget "$url_download"
	  fi

	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  clear
	  echo -e "[${gl_huang}2/2${gl_bai}] Путь, по которому находится index.html."
	  echo "-------------"
	  # find "$(realpath .)" -name "index.html" -print
	  find "$(realpath .)" -name "index.html" -print | xargs -I {} dirname {}

	  read -e -p "Введите путь к index.html, аналогичный (/home/web/html/$yuming/index/）： " index_lujing

	  sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
	  sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf

	  docker exec nginx chmod -R nginx:nginx /var/www/html
	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;







	31)
	  ldnmp_web_status
	  ;;


	32)
	  clear
	  send_stats "Резервное копирование среды LDNMP"

	  local backup_filename="web_$(date +"%Y%m%d%H%M%S").tar.gz"
	  echo -e "${gl_kjlan}Резервное копирование$backup_filename ...${gl_bai}"
	  cd /home/ && tar czvf "$backup_filename" web

	  while true; do
		clear
		echo "Создан файл резервной копии: /home/$backup_filename"
		read -e -p "Хотите перенести резервные данные на удаленный сервер? (Да/Нет):" choice
		case "$choice" in
		  [Yy])
			read -e -p "Пожалуйста, введите IP-адрес удаленного сервера:" remote_ip
			read -e -p "SSH-порт целевого сервера [по умолчанию 22]:" TARGET_PORT
			local TARGET_PORT=${TARGET_PORT:-22}
			if [ -z "$remote_ip" ]; then
			  echo "Ошибка: введите IP-адрес удаленного сервера."
			  continue
			fi
			local latest_tar=$(ls -t /home/*.tar.gz | head -1)
			if [ -n "$latest_tar" ]; then
			  ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
			  sleep 2  # 添加等待时间
			  scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/home/"
			  echo "Файл был перенесен в домашний каталог удаленного сервера."
			else
			  echo "Файл для передачи не найден."
			fi
			break
			;;
		  [Nn])
			break
			;;
		  *)
			echo "Неверный выбор, введите Y или N."
			;;
		esac
	  done
	  ;;

	33)
	  clear
	  send_stats "Запланированное удаленное резервное копирование"
	  read -e -p "Введите IP-адрес удаленного сервера:" useip
	  read -e -p "Введите пароль удаленного сервера:" usepasswd

	  cd ~
	  wget -O ${useip}_beifen.sh ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/beifen.sh > /dev/null 2>&1
	  chmod +x ${useip}_beifen.sh

	  sed -i "s/0.0.0.0/$useip/g" ${useip}_beifen.sh
	  sed -i "s/123456/$usepasswd/g" ${useip}_beifen.sh

	  echo "------------------------"
	  echo "1. Еженедельное резервное копирование 2. Ежедневное резервное копирование"
	  read -e -p "Пожалуйста, введите ваш выбор:" dingshi

	  case $dingshi in
		  1)
			  check_crontab_installed
			  read -e -p "Выберите день недели для еженедельного резервного копирования (0–6, 0 соответствует воскресенью):" weekday
			  (crontab -l ; echo "0 0 * * $weekday ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
			  ;;
		  2)
			  check_crontab_installed
			  read -e -p "Выберите ежедневное время резервного копирования (час, 0–23):" hour
			  (crontab -l ; echo "0 $hour * * * ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
			  ;;
		  *)
			  break  # 跳出
			  ;;
	  esac

	  install sshpass

	  ;;

	34)
	  root_use
	  send_stats "Восстановление среды LDNMP"
	  echo "Доступные резервные копии сайта"
	  echo "-------------------------"
	  ls -lt /home/*.gz | awk '{print $NF}'
	  echo ""
	  read -e -p  "Нажмите клавишу Enter, чтобы восстановить последнюю резервную копию, введите имя файла резервной копии, чтобы восстановить указанную резервную копию, введите 0, чтобы выйти:" filename

	  if [ "$filename" == "0" ]; then
		  break_end
		  linux_ldnmp
	  fi

	  # Если пользователь не вводит имя файла, используется последний сжатый пакет.
	  if [ -z "$filename" ]; then
		  local filename=$(ls -t /home/*.tar.gz | head -1)
	  fi

	  if [ -n "$filename" ]; then
		  cd /home/web/ > /dev/null 2>&1
		  docker compose down > /dev/null 2>&1
		  rm -rf /home/web > /dev/null 2>&1

		  echo -e "${gl_kjlan}Распаковка$filename ...${gl_bai}"
		  cd /home/ && tar -xzf "$filename"

		  install_dependency
		  install_docker
		  install_certbot
		  install_ldnmp
	  else
		  echo "Сжатый пакет не найден."
	  fi

	  ;;

	35)
		web_security
		;;

	36)
		web_optimization
		;;


	37)
	  root_use
	  while true; do
		  clear
		  send_stats "Обновить среду LDNMP"
		  echo "Обновить среду LDNMP"
		  echo "------------------------"
		  ldnmp_v
		  echo "Обнаружена новая версия компонента"
		  echo "------------------------"
		  check_docker_image_update nginx
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}nginx $update_status${gl_bai}"
		  fi
		  check_docker_image_update php
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}php $update_status${gl_bai}"
		  fi
		  check_docker_image_update mysql
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}mysql $update_status${gl_bai}"
		  fi
		  check_docker_image_update redis
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}redis $update_status${gl_bai}"
		  fi
		  echo "------------------------"
		  echo
		  echo "1. Обновить nginx 2. Обновить MySQL 3. Обновить php 4. Обновить Redis"
		  echo "------------------------"
		  echo "5. Обновите всю среду"
		  echo "------------------------"
		  echo "0. Вернуться в предыдущее меню"
		  echo "------------------------"
		  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
		  case $sub_choice in
			  1)
			  nginx_upgrade

				  ;;

			  2)
			  local ldnmp_pods="mysql"
			  read -e -p "Пожалуйста, введите${ldnmp_pods}Номер версии (например: 8.0 8.3 8.4 9.0) (нажмите Enter, чтобы получить последнюю версию):" version
			  local version=${version:-latest}

			  cd /home/web/
			  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml
			  sed -i "s/image: mysql/image: mysql:${version}/" /home/web/docker-compose.yml
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker restart $ldnmp_pods
			  cp /home/web/docker-compose1.yml /home/web/docker-compose.yml
			  send_stats "возобновлять$ldnmp_pods"
			  echo "возобновлять${ldnmp_pods}Заканчивать"

				  ;;
			  3)
			  local ldnmp_pods="php"
			  read -e -p "Пожалуйста, введите${ldnmp_pods}Номер версии (например: 7.4 8.0 8.1 8.2 8.3) (нажмите Enter, чтобы получить последнюю версию):" version
			  local version=${version:-8.3}
			  cd /home/web/
			  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml
			  sed -i "s/kjlion\///g" /home/web/docker-compose.yml > /dev/null 2>&1
			  sed -i "s/image: php:fpm-alpine/image: php:${version}-fpm-alpine/" /home/web/docker-compose.yml
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
  			  docker images --filter=reference="kjlion/${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker exec php chown -R www-data:www-data /var/www/html

			  run_command docker exec php sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories > /dev/null 2>&1

			  docker exec php apk update
			  curl -sL ${gh_proxy}github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions
			  docker exec php mkdir -p /usr/local/bin/
			  docker cp /usr/local/bin/install-php-extensions php:/usr/local/bin/
			  docker exec php chmod +x /usr/local/bin/install-php-extensions
			  docker exec php install-php-extensions mysqli pdo_mysql gd intl zip exif bcmath opcache redis imagick soap


			  docker exec php sh -c 'echo "upload_max_filesize=50M " > /usr/local/etc/php/conf.d/uploads.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "post_max_size=50M " > /usr/local/etc/php/conf.d/post.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_execution_time=1200" > /usr/local/etc/php/conf.d/max_execution_time.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_input_time=600" > /usr/local/etc/php/conf.d/max_input_time.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_input_vars=5000" > /usr/local/etc/php/conf.d/max_input_vars.ini' > /dev/null 2>&1

			  fix_phpfpm_con $ldnmp_pods

			  docker restart $ldnmp_pods > /dev/null 2>&1
			  cp /home/web/docker-compose1.yml /home/web/docker-compose.yml
			  send_stats "возобновлять$ldnmp_pods"
			  echo "возобновлять${ldnmp_pods}Заканчивать"

				  ;;
			  4)
			  local ldnmp_pods="redis"
			  cd /home/web/
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker restart $ldnmp_pods > /dev/null 2>&1
			  send_stats "возобновлять$ldnmp_pods"
			  echo "возобновлять${ldnmp_pods}Заканчивать"

				  ;;
			  5)
				read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}长时间不更新环境的用户，请慎重更新LDNMP环境，会有数据库更新失败的风险。确定更新LDNMP环境吗？(Y/N): ")" choice
				case "$choice" in
				  [Yy])
					send_stats "Полное обновление среды LDNMP"
					cd /home/web/
					docker compose down --rmi all

					install_dependency
					install_docker
					install_certbot
					install_ldnmp
					;;
				  *)
					;;
				esac
				  ;;
			  *)
				  break
				  ;;
		  esac
		  break_end
	  done


	  ;;

	38)
		root_use
		send_stats "Удалите среду LDNMP"
		read -e -p "$(echo -e "${gl_hong}强烈建议：${gl_bai}先备份全部网站数据，再卸载LDNMP环境。确定删除所有网站数据吗？(Y/N): ")" choice
		case "$choice" in
		  [Yy])
			cd /home/web/
			docker compose down --rmi all
			docker compose -f docker-compose.phpmyadmin.yml down > /dev/null 2>&1
			docker compose -f docker-compose.phpmyadmin.yml down --rmi all > /dev/null 2>&1
			rm -rf /home/web
			;;
		  [Nn])

			;;
		  *)
			echo "Неверный выбор, введите Y или N."
			;;
		esac
		;;

	0)
		kejilion
	  ;;

	*)
		echo "Неверный ввод!"
	esac
	break_end

  done

}






moltbot_menu() {
	local app_id="114"

	send_stats "управление clawdbot/moltbot"

	check_openclaw_update() {
		if ! command -v npm >/dev/null 2>&1; then
			return 1
		fi

		# Добавьте --no-update-notifier и убедитесь, что перенаправление ошибок находится в правильном месте.
		local_version=$(npm list -g openclaw --depth=0 --no-update-notifier 2>/dev/null | grep openclaw | awk '{print $NF}' | sed 's/^.*@//')

		if [ -z "$local_version" ]; then
			return 1
		fi

		remote_version=$(npm view openclaw version --no-update-notifier 2>/dev/null)

		if [ -z "$remote_version" ]; then
			return 1
		fi

		if [ "$local_version" != "$remote_version" ]; then
			echo "${gl_huang}Обнаружена новая версия:$remote_version${gl_bai}"
		else
			echo "${gl_lv}Текущая версия является последней:$local_version${gl_bai}"
		fi
	}

	get_install_status() {
		if command -v openclaw >/dev/null 2>&1; then
			echo "${gl_lv}Установлено${gl_bai}"
		else
			echo "${gl_hui}Не установлено${gl_bai}"
		fi
	}

	get_running_status() {
		if pgrep -f "openclaw gateway" >/dev/null 2>&1; then
			echo "${gl_lv}Бег${gl_bai}"
		else
			echo "${gl_hui}Не работает${gl_bai}"
		fi
	}

	show_menu() {


		clear

		local install_status=$(get_install_status)
		local running_status=$(get_running_status)
		local update_message=$(check_openclaw_update)

		echo "======================================="
		echo -e "ClawdBot > MoltBot > Управление OpenClaw"
		echo -e "$install_status $running_status $update_message"
		echo "======================================="
		echo "1. Установка"
		echo "2. Старт"
		echo "3. Стоп"
		echo "--------------------"
		echo "4. Просмотр журнала"
		echo "5. Сменить модель"
		echo "6. Добавьте API новой модели."
		echo "7. Введите код подключения в ТГ."
		echo "8. Установите плагины (например Feishu)"
		echo "9. Установите навыки"
		echo "10. Отредактируйте основной файл конфигурации."
		echo "11. Мастер настройки"
		echo "12. Обнаружение и восстановление работоспособности"
		echo "13. Доступ и настройки через веб-интерфейс"
		echo "--------------------"
		echo "14. Обновление"
		echo "15. Удалить"
		echo "--------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "--------------------"
		printf "Введите параметры и нажмите Enter:"
	}


	start_tmux() {
		install tmux
		openclaw gateway stop
		tmux kill-session -t gateway > /dev/null 2>&1
		tmux new -d -s gateway "openclaw gateway"
		check_crontab_installed
		crontab -l 2>/dev/null | grep -q "s gateway" || (crontab -l 2>/dev/null; echo "* * * * * tmux has-session -t gateway 2>/dev/null || tmux new -d -s gateway 'openclaw gateway'") | crontab -
		sleep 3
	}


	install_moltbot() {
		echo "Начать установку OpenClaw..."
		send_stats "Начать установку OpenClaw..."

		if command -v dnf &>/dev/null; then
			dnf update -y
			dnf groupinstall -y "Development Tools"
			dnf install -y cmake
		fi

		country=$(curl -s ipinfo.io/country)
		if [[ "$country" == "CN" || "$country" == "HK" ]]; then
			pnpm config set registry https://registry.npmmirror.com
			npm config set registry https://registry.npmmirror.com
		fi
		curl -fsSL https://openclaw.ai/install.sh | bash
		start_tmux
		add_app_id
		break_end

	}


	start_bot() {
		echo "Запускаем OpenClaw..."
		send_stats "Запускаем OpenClaw..."
		start_tmux
		break_end
	}

	stop_bot() {
		echo "Остановите OpenClaw..."
		send_stats "Остановите OpenClaw..."
		openclaw gateway stop
		tmux kill-session -t gateway > /dev/null 2>&1
		break_end
	}

	view_logs() {
		echo "Просмотрите журналы OpenClaw, нажмите Ctrl+C для выхода."
		send_stats "Просмотр журналов OpenClaw"
		openclaw logs
		break_end
	}





	# Основная функция: получить и добавить все модели
	add-all-models-from-provider() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"
		local config_file="${HOME}/.openclaw/openclaw.json"

		echo "🔍 Получение$provider_nameВсе доступные модели..."

		# Получить список моделей
		local models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -z "$models_json" ]]; then
			echo "❌ Невозможно получить список моделей."
			return 1
		fi

		# Извлеките все идентификаторы моделей
		local model_ids=$(echo "$models_json" | grep -oP '"id":\s*"\K[^"]+')

		if [[ -z "$model_ids" ]]; then
			echo "❌ Модели не найдены"
			return 1
		fi

		local model_count=$(echo "$model_ids" | wc -l)
		echo "✅ Откройте для себя$model_countмодели"

		# Интеллектуальный вывод параметров модели
		local models_array="["
		local first=true

		while read -r model_id; do
			[[ $first == false ]] && models_array+=","
			first=false

			# Окно вывода контекста на основе имени модели
			local context_window=131072
			local max_tokens=8192
			local input_cost=0.14
			local output_cost=0.28

			case "$model_id" in
				*preview*|*thinking*|*opus*|*pro*)
					context_window=1048576  # 1M
					max_tokens=16384
					input_cost=0.30
					output_cost=0.60
					;;
				*gpt-5*|*codex*)
					context_window=131072   # 128K
					max_tokens=8192
					input_cost=0.20
					output_cost=0.40
					;;
				*flash*|*lite*|*haiku*)
					context_window=131072
					max_tokens=8192
					input_cost=0.07
					output_cost=0.14
					;;
			esac

			models_array+=$(cat <<EOF
{
	"id": "$model_id",
	"name": "$provider_name / $model_id",
	"input": ["text", "image"],
	"contextWindow": $context_window,
	"maxTokens": $max_tokens,
	"cost": {
		"input": $input_cost,
		"output": $output_cost,
		"cacheRead": 0,
		"cacheWrite": 0
	}
}
EOF
)
		done <<< "$model_ids"

		models_array+="]"

		# Резервная конфигурация
		[[ -f "$config_file" ]] && cp "$config_file" "${config_file}.bak.$(date +%s)"

		# Внедрить все модели с помощью jq
		jq --arg prov "$provider_name" \
		   --arg url "$base_url" \
		   --arg key "$api_key" \
		   --argjson models "$models_array" \
		'
		.models |= (
			(. // { mode: "merge", providers: {} })
			| .mode = "merge"
			| .providers[$prov] = {
				baseUrl: $url,
				apiKey: $key,
				api: "openai-completions",
				models: $models
			}
		)
		' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"

		if [[ $? -eq 0 ]]; then
			echo "✅ Добавлено успешно$model_countмодели прибывают$provider_name"
			echo "📦 Формат ссылки на модель:$provider_name/<model-id>"
			return 0
		else
			echo "❌ Не удалось внедрить конфигурацию."
			return 1
		fi
	}

	add-openclaw-provider-interactive() {
		send_stats "Добавить API"
		echo "=== Интерактивное добавление поставщика OpenClaw (полная модель) ==="

		# 1. Имя провайдера
		read -erp "Введите имя провайдера (например: deepseek):" provider_name
		while [[ -z "$provider_name" ]]; do
			echo "❌ Имя провайдера не может быть пустым."
			read -erp "Пожалуйста, введите имя провайдера:" provider_name
		done

		# 2. Base URL
		read -erp "Введите базовый URL-адрес (например: https://api.xxx.com/v1):" base_url
		while [[ -z "$base_url" ]]; do
			echo "❌ Базовый URL не может быть пустым."
			read -erp "Введите базовый URL:" base_url
		done
		base_url="${base_url%/}"

		# 3. API Key
		read -rsp "Пожалуйста, введите ключ API (ввод не будет отображаться):" api_key
		echo
		while [[ -z "$api_key" ]]; do
			echo "❌ Ключ API не может быть пустым."
			read -rsp "Пожалуйста, введите ключ API:" api_key
			echo
		done

		# 4. Получите список моделей.
		echo "🔍 Получение списка доступных моделей..."
		models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -n "$models_json" ]]; then
			available_models=$(echo "$models_json" | grep -oP '"id":\s*"\K[^"]+' | sort)

			if [[ -n "$available_models" ]]; then
				model_count=$(echo "$available_models" | wc -l)
				echo "✅ Откройте для себя$model_countДоступные модели:"
				echo "--------------------------------"
				# Показать все, с серийным номером
				i=1
				declare -A model_map
				while read -r model; do
					echo "[$i] $model"
					model_map[$i]="$model"
					((i++))
				done <<< "$available_models"
				echo "--------------------------------"
			fi
		fi

		# 5. Выберите модель по умолчанию.
		echo
		read -erp "Введите идентификатор модели по умолчанию (или серийный номер, оставьте пустым, чтобы использовать первый):" input_model

		if [[ -z "$input_model" && -n "$available_models" ]]; then
			default_model=$(echo "$available_models" | head -1)
			echo "🎯 Используя первую модель:$default_model"
		elif [[ -n "${model_map[$input_model]}" ]]; then
			default_model="${model_map[$input_model]}"
			echo "🎯Выбранные модели:$default_model"
		else
			default_model="$input_model"
		fi

		# 6. Подтвердите информацию
		echo
		echo "====== Подтверждение ======"
		echo "Provider    : $provider_name"
		echo "Base URL    : $base_url"
		echo "API Key     : ${api_key:0:8}****"
		echo "Модель по умолчанию:$default_model"
		echo "Общее количество моделей:$model_count"
		echo "======================"

		read -erp "Подтвердите добавление всех$model_countМодель? (да/нет):" confirm
		if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
			echo "❎ Отменено"
			return 1
		fi

		install jq
		add-all-models-from-provider "$provider_name" "$base_url" "$api_key"

		if [[ $? -eq 0 ]]; then
			echo
			echo "🔄 Установите модель по умолчанию и перезапустите шлюз..."
			openclaw models set "$provider_name/$default_model"
			start_tmux
			echo "✅ Готово! все$model_countмодели загружены"
		fi

		break_end
	}



	change_model() {
		send_stats "Изменить модель"

		while true; do
			clear
			echo "--- Управление моделями ---"
			echo "Все модели:"
			openclaw models list --all
			echo "----------------"
			echo "Текущая модель:"
			openclaw models list
			echo "----------------"
			read -e -p "Введите название модели для установки (например, openrouter/openai/gpt-4o) (введите 0 для выхода):" model

			# 1. Проверьте, ввели ли вы 0 для выхода.
			if [ "$model" = "0" ]; then
				echo "Операция отменена, выход..."
				break  # 跳出 while 循环

			fi

			# 2. Убедитесь, что ввод пуст.
			if [ -z "$model" ]; then
				echo "Ошибка: имя модели не может быть пустым. Пожалуйста, попробуйте еще раз."
				echo "" # 换行美化
				continue # 跳过本次循环，重新开始
			fi

			# 3. Выполнить логику переключения
			echo "Переключаемая модель:$model ..."
			openclaw models set "$model"

			break_end
		done

	}




	install_plugin() {

		send_stats "Установить плагин"
		while true; do
			clear
			echo "========================================"
			echo "Управление плагинами (установка)"
			echo "========================================"
			echo "Установленные на данный момент плагины:"
			openclaw plugins list
			echo "----------------------------------------"

			# Выведите список рекомендуемых практических плагинов для копирования пользователями.
			echo "Рекомендуемые практические плагины (вы можете напрямую скопировать ввод имени):"
			echo "feishu # Интеграция Feishu/Lark (в данный момент загружена ✓)"
			echo "Telegram # Интеграция бота Telegram (сейчас загружен ✓)"
			echo "Memory-core # Улучшение основной памяти: контекстный поиск по файлам (в данный момент загружен ✓)"
			echo "@openclaw/slack # Глубокие связи между каналами Slack и личными сообщениями."
			echo "@openclaw/bluebubbles # мост iMessage (предпочтительно для пользователей macOS)"
			echo "@openclaw/msteams #Интеграция корпоративных коммуникаций Microsoft Teams"
			echo "@openclaw/voice-call # Плагин голосового вызова (на основе бэкендов, таких как Twilio)"
			echo "@openclaw/discord # автоматическое управление каналом Discord"
			echo "@openclaw/nostr # Протокол Nostr: приватный и безопасный зашифрованный чат"
			echo "lobster # Рабочий процесс утверждения: автоматизированные задачи с участием человека"
			echo "Memory-lancedb # Улучшение долговременной памяти: точное воспроизведение на основе векторной базы данных"
			echo "copilot-proxy # Улучшение доступа к прокси-серверу GitHub Copilot"
			echo "----------------------------------------"

			# Запросить у пользователя имя плагина
			read -e -p "Пожалуйста, введите имя плагина, который вы хотите установить (введите 0 для выхода):" plugin_name

			# 1. Проверьте, ввели ли вы 0 для выхода.
			if [ "$plugin_name" = "0" ]; then
				echo "Операция была отменена, и установка плагина завершена."
				break
			fi

			# 2. Убедитесь, что ввод пуст.
			if [ -z "$plugin_name" ]; then
				echo "Ошибка: Имя плагина не может быть пустым, введите его еще раз."
				echo ""
				continue
			fi

			# 1. Полностью почистить остатки предыдущих сбоев (каталог пользователя)
			rm -rf "/root/.openclaw/extensions/$plugin_name"

			# 2. Проверьте, была ли система предварительно установлена ​​(во избежание конфликтов дубликатов идентификаторов).
			if [ -d "/usr/lib/node_modules/openclaw/extensions/$plugin_name" ]; then
				echo "💡 Обнаружено, что плагин уже существует в системном каталоге и активируется напрямую..."
				openclaw plugins enable "$plugin_name"
			else
				echo "📥 Скачивание и установка плагинов по официальным каналам..."
				# Используйте собственную команду установки openclaw, которая автоматически выполняет проверку спецификации package.json.
				openclaw plugins install "$plugin_name"

				# 3. Если установка openclaw сообщает об ошибке, попробуйте установить ее как обычный пакет npm (последний вариант).
				if [ $? -ne 0 ]; then
					echo "⚠️ Официальная установка не удалась, попробуйте принудительно установить глобально через npm..."
					npm install -g "$plugin_name" --unsafe-perm
				fi

				# 4. Наконец, унифицированное выполнение и активация.
				openclaw plugins enable "$plugin_name"
			fi

			start_tmux
			break_end
		done
	}

	install_plugin() {
		send_stats "Установить плагин"
		while true; do
			clear
			echo "========================================"
			echo "Управление плагинами (установка)"
			echo "========================================"
			echo "Текущий список плагинов:"
			openclaw plugins list
			echo "--------------------------------------------------------"
			echo "Рекомендуемые часто используемые идентификаторы плагинов (просто скопируйте идентификатор в скобках):"
			echo "--------------------------------------------------------"
			echo "📱 Каналы связи:"
			echo "- [feishu] # Интеграция Feishu/Lark"
			echo "- [telegram] # Telegram-бот"
			echo "- [slack] #Slack Корпоративные коммуникации"
			echo "  - [msteams]      	# Microsoft Teams"
			echo "- [discord] # Управление сообществом Discord"
			echo "- [whatsapp] #WhatsApp Automation"
			echo ""
			echo "🧠 Память и искусственный интеллект:"
			echo "- [memory-core] # Базовая память (извлечение файлов)"
			echo "- [memory-lancedb] # Расширенная память (векторная база данных)"
			echo "- [copilot-proxy] # Перенаправление интерфейса второго пилота"
			echo ""
			echo "⚙️Расширение функций:"
			echo "- [lobster] # Порядок утверждения (с подтверждением вручную)"
			echo "- [голосовой вызов] # Возможность голосового вызова"
			echo "- [nostr]# Зашифрованный приватный чат"
			echo "--------------------------------------------------------"

			read -e -p "Пожалуйста, введите идентификатор плагина (введите 0 для выхода):" raw_input

			[ "$raw_input" = "0" ] && break
			[ -z "$raw_input" ] && continue

			# 1. Автоматическая обработка: если пользовательский ввод содержит @openclaw/, извлеките чистый идентификатор, чтобы облегчить проверку пути.
			local plugin_id=$(echo "$raw_input" | sed 's|^@openclaw/||')
			local plugin_full="$raw_input"

			echo "🔍 Проверка статуса плагина..."

			# 2. Проверьте, есть ли он уже в списке и отключен ли он (самый распространенный случай)
			if echo "$plugin_list" | grep -qW "$plugin_id" && echo "$plugin_list" | grep "$plugin_id" | grep -q "disabled"; then
				echo "💡 Плагин [$plugin_id] Предустановлено, активация..."
				openclaw plugins enable "$plugin_id" && echo "✅Активация прошла успешно" || echo "❌ Активация не удалась"

			# 3. Проверьте, существует ли физический каталог системы.
			elif [ -d "/usr/lib/node_modules/openclaw/extensions/$plugin_id" ]; then
				echo "💡 Обнаружил, что плагин существует во встроенной директории системы, попробуйте включить его напрямую..."
				openclaw plugins enable "$plugin_id"

			else
				# 4. Логика удаленной установки
				echo "📥 Не найден локально, попробуйте скачать и установить..."

				# Очистите старые неудавшиеся остатки
				rm -rf "/root/.openclaw/extensions/$plugin_id"

				# Выполните установку и зафиксируйте результаты
				if openclaw plugins install "$plugin_full"; then
					echo "✅ Загрузка прошла успешно, активация..."
					openclaw plugins enable "$plugin_id"
				else
					echo "⚠️ Не удалось скачать с официальных каналов, попробуйте альтернативы..."
					# Альтернативная установка npm
					if npm install -g "$plugin_full" --unsafe-perm; then
						echo "✅ npm успешно установлен, попробуйте включить..."
						openclaw plugins enable "$plugin_id"
					else
						echo "❌ Неустранимая ошибка: невозможно получить плагин. Пожалуйста, проверьте правильность идентификатора и доступность сети."
						# Ключ: вернитесь или продолжите прямо здесь, а не start_tmux ниже, чтобы предотвратить жесткое кодирование конфигурации.
						break_end
						continue
					fi
				fi
			fi

			echo "🔄 Перезапуск службы OpenClaw для загрузки новых плагинов..."
			start_tmux
			break_end
		done
	}







	install_skill() {
		send_stats "Навыки установки"
		while true; do
			clear
			echo "========================================"
			echo "Управление навыками (установка)"
			echo "========================================"
			echo "Установленные на данный момент навыки:"
			openclaw skills list
			echo "----------------------------------------"

			# Выведите список рекомендуемых практических навыков
			echo "Рекомендуемые практические навыки (можно напрямую скопировать имя и ввести его):"
			echo "github # Управление проблемами GitHub/PR/CI (gh CLI)"
			echo "notion # Манипулирование страницами, базами данных и блоками Notion"
			echo "apple-notes # встроенное управление заметками macOS (создание/редактирование/поиск)"
			echo "apple-reminders # управление напоминаниями в macOS (список дел)"
			echo "1password # Автоматизировать чтение и внедрение ключей 1Password."
			echo "gog # Google Workspace (Gmail/облачный диск/документы) универсальный помощник"
			echo "Things-mac # Глубокая интеграция управления задачами Things 3"
			echo "bluebubbles # Идеально отправляйте и получайте iMessages с помощью BlueBubbles"
			echo "Himalaya # Управление почтой терминала (мощный инструмент IMAP/SMTP)"
			echo "Сводка # Сводка веб-страницы, подкаста или видеоконтента YouTube в один клик."
			echo "openhue # Управление сценами интеллектуального освещения Philips Hue"
			echo "video-frames # Извлечение видеокадров и редактирование коротких клипов (драйвер ffmpeg)"
			echo "openai-whisper # Преобразование локального аудио в текст (защита конфиденциальности в автономном режиме)"
			echo "coding-agent # Автоматически запускать помощники по программированию, такие как Claude Code/Codex"
			echo "----------------------------------------"

			# Предложить пользователю ввести название навыка
			read -e -p "Пожалуйста, введите название навыка, который необходимо установить (для выхода введите 0):" skill_name

			# 1. Проверьте, ввели ли вы 0 для выхода.
			if [ "$skill_name" = "0" ]; then
				echo "Операция была отменена, и установка навыка завершена."
				break
			fi

			# 2. Убедитесь, что ввод пуст.
			if [ -z "$skill_name" ]; then
				echo "Ошибка: имя навыка не может быть пустым. Пожалуйста, попробуйте еще раз."
				echo ""
				continue
			fi

			# 3. Выполните команду установки.
			echo "Навыки установки:$skill_name ..."
			npx clawhub install "$skill_name"

			# Получить статус завершения предыдущей команды
			if [ $? -eq 0 ]; then
				echo "✅ Навыки$skill_nameУстановка прошла успешно."
				# Выполнить логику перезапуска/запуска службы
				start_tmux
			else
				echo "❌ Установка не удалась. Проверьте правильность названия навыка или обратитесь к документации для устранения неполадок."
			fi

			break_end
		done

	}



	change_tg_bot_code() {
		send_stats "Стыковка роботов"
		read -e -p "Введите код подключения, полученный роботом TG (например, код сопряжения: NYA99R2F) (введите 0 для выхода):" code

		# Проверьте, введен ли 0 для выхода
		if [ "$code" = "0" ]; then
			echo "Операция отменена."
			return 0  # 正常退出函数
		fi

		# Убедитесь, что ввод пуст
		if [ -z "$code" ]; then
			echo "Ошибка: Код подключения не может быть пустым. Пожалуйста, попробуйте еще раз."
			return 1
		fi

		openclaw pairing approve telegram $code
		break_end
	}


	update_moltbot() {
		echo "Обновить OpenClaw..."
		send_stats "Обновить OpenClaw..."
		curl -fsSL https://openclaw.ai/install.sh | bash
		openclaw gateway stop
		start_tmux
		add_app_id
		echo "Обновление завершено"
		break_end
	}


	uninstall_moltbot() {
		echo "Удалить OpenClaw..."
		send_stats "Удалить OpenClaw..."
		openclaw uninstall
		npm uninstall -g openclaw
		crontab -l 2>/dev/null | grep -v "s gateway" | crontab -
		hash -r
		sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
		echo "Удаление завершено"
		break_end
	}

	nano_openclaw_json() {
		send_stats "Отредактируйте файл конфигурации OpenClaw."
		install nano
		nano ~/.openclaw/openclaw.json
		start_tmux
	}






	openclaw_find_webui_domain() {
		local conf domain_list

		domain_list=$(
			grep -R "18789" /home/web/conf.d/*.conf 2>/dev/null \
			| awk -F: '{print $1}' \
			| sort -u \
			| while read conf; do
				basename "$conf" .conf
			done
		)

		if [ -n "$domain_list" ]; then
			echo "$domain_list"
		fi
	}



	openclaw_show_webui_addr() {
		local local_ip token domains

		echo "=================================="
		echo "Адрес доступа к веб-интерфейсу OpenClaw"
		local_ip="127.0.0.1"

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/?token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)
		echo
		echo "Местный адрес:"
		echo "http://${local_ip}:18789/?token=${token}"

		domains=$(openclaw_find_webui_domain)
		if [ -n "$domains" ]; then
			echo "Адрес доменного имени:"
			echo "$domains" | while read d; do
				echo "https://${d}/?token=${token}"
			done
		fi

		echo "=================================="
	}



	# Добавьте доменное имя (вызовите указанную вами функцию)
	openclaw_domain_webui() {
		add_yuming
		ldnmp_Proxy ${yuming} 127.0.0.1 18789

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/?token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)

		clear
		echo "Адрес посещения:"
		echo "https://${yuming}/?token=$token"
		echo "Сначала откройте URL-адрес, чтобы активировать идентификатор устройства, затем нажмите Enter, чтобы продолжить сопряжение."
		read
		echo -e "${gl_kjlan}Загрузка списка устройств...${gl_bai}"
		openclaw devices list

		read -e -p "Пожалуйста, введите Request_Key:" Request_Key

		[ -z "$Request_Key" ] && {
			echo "Request_Key не может быть пустым."
			return 1
		}

		openclaw devices approve "$Request_Key"

	}

	# Удалить доменное имя
	openclaw_remove_domain() {
		echo "Формат доменного имени example.com без https://"
		web_del
	}

	# Главное меню
	openclaw_webui_menu() {

		send_stats "Доступ и настройки через веб-интерфейс"
		while true; do
			clear
			openclaw_show_webui_addr
			echo
			echo "1. Добавьте доступ к доменному имени"
			echo "2. Удаление доступа к доменному имени"
			echo "0. Выход"
			echo
			read -e -p "Пожалуйста, выберите:" choice

			case "$choice" in
				1)
					openclaw_domain_webui
					echo
					read -p "Нажмите Enter, чтобы вернуться в меню..."
					;;
				2)
					openclaw_remove_domain
					read -p "Нажмите Enter, чтобы вернуться в меню..."
					;;
				0)
					break
					;;
				*)
					echo "Неверный вариант"
					sleep 1
					;;
			esac
		done
	}



	# основной цикл
	while true; do
		show_menu
		read choice
		case $choice in
			1) install_moltbot ;;
			2) start_bot ;;
			3) stop_bot ;;
			4) view_logs ;;
			5) change_model ;;
			6) add-openclaw-provider-interactive ;;
			7) change_tg_bot_code ;;
			8) install_plugin ;;
			9) install_skill ;;
			10) nano_openclaw_json ;;
			11) send_stats "Мастер первоначальной настройки"
				openclaw onboard --install-daemon
				break_end
				;;
			12) send_stats "Обнаружение и восстановление работоспособности"
				openclaw doctor --fix
				break_end
			 	;;
			13) openclaw_webui_menu ;;
			14) update_moltbot ;;
			15) uninstall_moltbot ;;
			*) break ;;
		esac
	done

}




linux_panel() {

local sub_choice="$1"

clear
cd ~
install git
echo -e "${gl_kjlan}Список приложений обновляется. Пожалуйста, подождите...${gl_bai}"
if [ ! -d apps/.git ]; then
	timeout 10s git clone ${gh_proxy}github.com/kejilion/apps.git
else
	cd apps
	# git pull origin main > /dev/null 2>&1
	timeout 10s git pull ${gh_proxy}github.com/kejilion/apps.git main > /dev/null 2>&1
fi

while true; do

	if [ -z "$sub_choice" ]; then
	  clear
	  echo -e "рынок приложений"
	  echo -e "${gl_kjlan}-------------------------"

	  local app_numbers=$([ -f /home/docker/appno.txt ] && cat /home/docker/appno.txt || echo "")

	  # Установить цвет с помощью цикла
	  for i in {1..150}; do
		  if echo "$app_numbers" | grep -q "^$i$"; then
			  declare "color$i=${gl_lv}"
		  else
			  declare "color$i=${gl_bai}"
		  fi
	  done

	  echo -e "${gl_kjlan}1.   ${color1}Официальная версия панели пагоды${gl_kjlan}2.   ${color2}aaPanel Пагода Международная версия"
	  echo -e "${gl_kjlan}3.   ${color3}Панель управления нового поколения 1Panel${gl_kjlan}4.   ${color4}Панель визуализации NginxProxyManager"
	  echo -e "${gl_kjlan}5.   ${color5}Программа OpenList для создания списка файлов из нескольких магазинов${gl_kjlan}6.   ${color6}Веб-версия удаленного рабочего стола Ubuntu"
	  echo -e "${gl_kjlan}7.   ${color7}Панель мониторинга Nezha Probe VPS${gl_kjlan}8.   ${color8}QB автономная магнитная панель загрузки BT"
	  echo -e "${gl_kjlan}9.   ${color9}Программа почтового сервера Poste.io${gl_kjlan}10.  ${color10}Система онлайн-чата для нескольких человек RocketChat"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}11.  ${color11}Программное обеспечение для управления проектами ZenTao${gl_kjlan}12.  ${color12}Платформа управления запланированными задачами панели Qinglong"
	  echo -e "${gl_kjlan}13.  ${color13}Сетевой диск Cloudreve${gl_huang}★${gl_bai}                     ${gl_kjlan}14.  ${color14}Простая программа для управления изображениями на кровати."
	  echo -e "${gl_kjlan}15.  ${color15}встроенная система управления мультимедиа${gl_kjlan}16.  ${color16}Панель проверки скорости Speedtest"
	  echo -e "${gl_kjlan}17.  ${color17}AdGuardHome удаляет рекламное ПО${gl_kjlan}18.  ${color18}onlyofficeИнтернет-офис OFFICE"
	  echo -e "${gl_kjlan}19.  ${color19}Панель брандмауэра Leichi WAF${gl_kjlan}20.  ${color20}панель управления контейнером portainer"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}21.  ${color21}Веб-версия VScode${gl_kjlan}22.  ${color22}Инструмент мониторинга UptimeKuma"
	  echo -e "${gl_kjlan}23.  ${color23}Веб-памятка для заметок${gl_kjlan}24.  ${color24}Веб-версия удаленного рабочего стола Webtop${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}25.  ${color25}Сетевой диск Nextcloud${gl_kjlan}26.  ${color26}Система управления запланированными задачами QD-Today"
	  echo -e "${gl_kjlan}27.  ${color27}Панель управления штабелем контейнеров Dockge${gl_kjlan}28.  ${color28}Инструмент проверки скорости LibreSpeed"
	  echo -e "${gl_kjlan}29.  ${color29}агрегированная поисковая станция searchxng${gl_huang}★${gl_bai}                 ${gl_kjlan}30.  ${color30}Система личных альбомов PhotoPrism"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}31.  ${color31}Коллекция инструментов StirlingPDF${gl_kjlan}32.  ${color32}Drawio — бесплатная программа для построения онлайн-графиков${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${color33}Панель навигации Sun-Panel${gl_kjlan}34.  ${color34}Платформа обмена файлами Pingvin-Share"
	  echo -e "${gl_kjlan}35.  ${color35}Минималистский круг друзей${gl_kjlan}36.  ${color36}Сайт-агрегатор чатов LobeChatAI"
	  echo -e "${gl_kjlan}37.  ${color37}Панель инструментов MyIP${gl_huang}★${gl_bai}                        ${gl_kjlan}38.  ${color38}Семейное ведро Xiaoya alist"
	  echo -e "${gl_kjlan}39.  ${color39}Инструмент для записи прямых трансляций Bililive${gl_kjlan}40.  ${color40}веб-версия webssh, инструмент подключения SSH"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}41.  ${color41}Панель управления мышью${gl_kjlan}42.  ${color42}Инструмент удаленного подключения Nexterm"
	  echo -e "${gl_kjlan}43.  ${color43}Удаленный рабочий стол RustDesk (сервер)${gl_huang}★${gl_bai}          ${gl_kjlan}44.  ${color44}Удаленный рабочий стол RustDesk (реле)${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}45.  ${color45}Докер-ускорительная станция${gl_kjlan}46.  ${color46}Станция ускорения GitHub${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}47.  ${color47}Мониторинг Прометея${gl_kjlan}48.  ${color48}Прометей (мониторинг хоста)"
	  echo -e "${gl_kjlan}49.  ${color49}Прометей (мониторинг контейнеров)${gl_kjlan}50.  ${color50}Инструменты мониторинга пополнения запасов"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}51.  ${color51}PVE открытая панель для цыплят${gl_kjlan}52.  ${color52}Панель управления контейнером DPanel"
	  echo -e "${gl_kjlan}53.  ${color53}llama3 чат AI большая модель${gl_kjlan}54.  ${color54}Панель управления созданием хост-сайта AMH"
	  echo -e "${gl_kjlan}55.  ${color55}Проникновение FRP в интранет (сервер)${gl_huang}★${gl_bai}	         ${gl_kjlan}56.  ${color56}Проникновение FRP в интранет (клиент)${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}57.  ${color57}Deepseek чат AI большая модель${gl_kjlan}58.  ${color58}База знаний больших моделей Dify${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}59.  ${color59}Управление активами крупных моделей NewAPI${gl_kjlan}60.  ${color60}JumpServer — бастионная машина с открытым исходным кодом"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}61.  ${color61}Сервер онлайн-переводов${gl_kjlan}62.  ${color62}База знаний по большим моделям RAGFlow"
	  echo -e "${gl_kjlan}63.  ${color63}Автономная платформа искусственного интеллекта OpenWebUI${gl_huang}★${gl_bai}             ${gl_kjlan}64.  ${color64}набор инструментов it-tools"
	  echo -e "${gl_kjlan}65.  ${color65}платформа автоматизированного рабочего процесса n8n${gl_huang}★${gl_bai}               ${gl_kjlan}66.  ${color66}инструмент yt-dlp для загрузки видео"
	  echo -e "${gl_kjlan}67.  ${color67}ddns-go инструмент управления динамическим DNS${gl_huang}★${gl_bai}            ${gl_kjlan}68.  ${color68}Платформа управления сертификатами AllinSSL"
	  echo -e "${gl_kjlan}69.  ${color69}Инструмент передачи файлов STFTPGo${gl_kjlan}70.  ${color70}Платформа чат-бота AstrBot"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}71.  ${color71}Частный музыкальный сервер Navidrome${gl_kjlan}72.  ${color72}менеджер паролей BitWarden${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}73.  ${color73}Частные фильмы LibreTV${gl_kjlan}74.  ${color74}Частные фильмы MoonTV"
	  echo -e "${gl_kjlan}75.  ${color75}Мастер мелодической музыки${gl_kjlan}76.  ${color76}Онлайн старые игры для DOS"
	  echo -e "${gl_kjlan}77.  ${color77}Инструмент автономной загрузки Thunder${gl_kjlan}78.  ${color78}Интеллектуальная система управления документами PandaWiki"
	  echo -e "${gl_kjlan}79.  ${color79}Мониторинг серверов Beszel${gl_kjlan}80.  ${color80}управление закладками Linkwarden"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}81.  ${color81}Видеоконференция JitsiMeet${gl_kjlan}82.  ${color82}gpt-load высокопроизводительный прозрачный прокси с искусственным интеллектом"
	  echo -e "${gl_kjlan}83.  ${color83}инструмент мониторинга сервера komari${gl_kjlan}84.  ${color84}Инструмент управления личными финансами Wallos"
	  echo -e "${gl_kjlan}85.  ${color85}immich фото-видео-менеджер${gl_kjlan}86.  ${color86}система управления медиа-файлами Jellyfin"
	  echo -e "${gl_kjlan}87.  ${color87}SyncTV — отличный инструмент для совместного просмотра фильмов${gl_kjlan}88.  ${color88}Собственная платформа для прямых трансляций Owncast"
	  echo -e "${gl_kjlan}89.  ${color89}Экспресс-файл FileCodeBox${gl_kjlan}90.  ${color90}матричный протокол децентрализованного чата"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}91.  ${color91}хранилище частного кода gitea${gl_kjlan}92.  ${color92}Файловый менеджер FileBrowser"
	  echo -e "${gl_kjlan}93.  ${color93}Минималистичный статический файловый сервер Dufs${gl_kjlan}94.  ${color94}Инструмент высокоскоростной загрузки Gopeed"
	  echo -e "${gl_kjlan}95.  ${color95}платформа управления безбумажными документами${gl_kjlan}96.  ${color96}Самостоятельный двухэтапный аутентификатор 2FAuth"
	  echo -e "${gl_kjlan}97.  ${color97}Сеть WireGuard (сервер)${gl_kjlan}98.  ${color98}Сеть WireGuard (клиент)"
	  echo -e "${gl_kjlan}99.  ${color99}Виртуальная машина Synology DSM${gl_kjlan}100. ${color100}Инструмент одноранговой синхронизации файлов Syncthing"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}101. ${color101}Инструмент для создания видео с использованием искусственного интеллекта${gl_kjlan}102. ${color102}Система онлайн-чата для нескольких человек VoceChat"
	  echo -e "${gl_kjlan}103. ${color103}Инструмент статистики сайта Umami${gl_kjlan}104. ${color104}Инструмент четырехуровневой переадресации прокси-сервера Stream"
	  echo -e "${gl_kjlan}105. ${color105}Сиюаньские заметки${gl_kjlan}106. ${color106}Инструмент для создания досок Drawnix с открытым исходным кодом"
	  echo -e "${gl_kjlan}107. ${color107}Поиск сетевого диска PanSou${gl_kjlan}108. ${color108}Чат-бот LangBot"
	  echo -e "${gl_kjlan}109. ${color109}Сетевой онлайн-диск ZFile${gl_kjlan}110. ${color110}Управление закладками Каракипа"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}111. ${color111}Многоформатный инструмент для преобразования файлов${gl_kjlan}112. ${color112}Удачный крупный инструмент для проникновения в интранет"
	  echo -e "${gl_kjlan}113. ${color113}Браузер Фаерфокс${gl_kjlan}114. ${color114}Робот ClawdBot/Moltbot${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}Список сторонних приложений"
  	  echo -e "${gl_kjlan}Хотите, чтобы ваше приложение появилось здесь? Ознакомьтесь с руководством разработчика:${gl_huang}https://dev.kejilion.sh/${gl_bai}"

	  for f in "$HOME"/apps/*.conf; do
		  [ -e "$f" ] || continue
		  local base_name=$(basename "$f" .conf)
		  # Получить описание приложения
		  local app_text=$(grep "app_text=" "$f" | cut -d'=' -f2 | tr -d '"' | tr -d "'")

		  # Проверьте статус установки (соответствует идентификатору в appno.txt)
		  # Здесь предполагается, что в appno.txt записано base_name (т. е. имя файла).
		  if echo "$app_numbers" | grep -q "^$base_name$"; then
			  # Если установлено: показать имя_базы - описание [Установлено] (зеленый)
			  echo -e "${gl_kjlan}$base_name${gl_bai} - ${gl_lv}$app_text[Установлено]${gl_bai}"
		  else
			  # Если не установлено: отображается нормально
			  echo -e "${gl_kjlan}$base_name${gl_bai} - $app_text"
		  fi
	  done



	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}b.   ${gl_bai}Резервное копирование всех данных приложения${gl_kjlan}r.   ${gl_bai}Восстановить все данные приложения"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
	fi

	case $sub_choice in
	  1|bt|baota)
		local app_id="1"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="панель пагоды"
		local panelurl="https://www.bt.cn/new/index.html"

		panel_app_install() {
			if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
		}

		panel_app_manage() {
			bt
		}

		panel_app_uninstall() {
			curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh
			chmod +x bt-uninstall.sh
			./bt-uninstall.sh
		}

		install_panel



		  ;;
	  2|aapanel)


		local app_id="2"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="aapanel"
		local panelurl="https://www.aapanel.com/new/index.html"

		panel_app_install() {
			URL=https://www.aapanel.com/script/install_7.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel
		}

		panel_app_manage() {
			bt
		}

		panel_app_uninstall() {
			curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh
			chmod +x bt-uninstall.sh
			./bt-uninstall.sh
		}

		install_panel

		  ;;
	  3|1p|1panel)

		local app_id="3"
		local lujing="command -v 1pctl"
		local panelname="1Panel"
		local panelurl="https://1panel.cn/"

		panel_app_install() {
			install bash
			bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"
		}

		panel_app_manage() {
			1pctl user-info
			1pctl update password
		}

		panel_app_uninstall() {
			1pctl uninstall
		}

		install_panel

		  ;;
	  4|npm)

		local app_id="4"
		local docker_name="npm"
		local docker_img="jc21/nginx-proxy-manager:latest"
		local docker_port=81

		docker_rum() {

			docker run -d \
			  --name=$docker_name \
			  -p ${docker_port}:81 \
			  -p 80:80 \
			  -p 443:443 \
			  -v /home/docker/npm/data:/data \
			  -v /home/docker/npm/letsencrypt:/etc/letsencrypt \
			  --restart=always \
			  $docker_img


		}

		local docker_describe="Панель инструментов обратного прокси-сервера Nginx, которая не поддерживает добавление доступа к доменному имени."
		local docker_url="Официальный сайт: https://nginxproxymanager.com/"
		local docker_use="echo \"Исходное имя пользователя: admin@example.com\""
		local docker_passwd="echo \"Начальный пароль: изменить меня\""
		local app_size="1"

		docker_app

		  ;;

	  5|openlist)

		local app_id="5"
		local docker_name="openlist"
		local docker_img="openlistteam/openlist:latest-aria2"
		local docker_port=5244

		docker_rum() {

			mkdir -p /home/docker/openlist
			chmod -R 777 /home/docker/openlist

			docker run -d \
				--restart=always \
				-v /home/docker/openlist:/opt/openlist/data \
				-p ${docker_port}:5244 \
				-e PUID=0 \
				-e PGID=0 \
				-e UMASK=022 \
				--name="openlist" \
				openlistteam/openlist:latest-aria2

		}


		local docker_describe="Программа просмотра файлов, поддерживающая несколько хранилищ, просмотр веб-страниц и WebDAV, работающая на базе gin и Solidjs."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/OpenListTeam/OpenList"
		local docker_use="docker exec openlist ./openlist admin random"
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  6|webtop-ubuntu)

		local app_id="6"
		local docker_name="webtop-ubuntu"
		local docker_img="lscr.io/linuxserver/webtop:ubuntu-kde"
		local docker_port=3006

		docker_rum() {

			read -e -p "Установите имя пользователя для входа:" admin
			read -e -p "Установите пароль пользователя для входа:" admin_password
			docker run -d \
			  --name=webtop-ubuntu \
			  --security-opt seccomp=unconfined \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e SUBFOLDER=/ \
			  -e TITLE=Webtop \
			  -e CUSTOM_USER=${admin} \
			  -e PASSWORD=${admin_password} \
			  -p ${docker_port}:3000 \
			  -v /home/docker/webtop/data:/config \
			  -v /var/run/docker.sock:/var/run/docker.sock \
			  --shm-size="1gb" \
			  --restart=always \
			  lscr.io/linuxserver/webtop:ubuntu-kde


		}


		local docker_describe="webtop — это контейнер на базе Ubuntu. Если доступ к IP-адресу невозможен, добавьте доменное имя для доступа."
		local docker_url="Официальный сайт: https://docs.linuxserver.io/images/docker-webtop/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app


		  ;;
	  7|nezha)
		clear
		send_stats "Построить Нежу"

		local app_id="7"
		local docker_name="nezha-dashboard"
		local docker_port=8008
		while true; do
			check_docker_app
			check_docker_image_update $docker_name
			clear
			echo -e "Нежа мониторинг$check_docker $update_status"
			echo "Легкий и простой в использовании инструмент с открытым исходным кодом, для мониторинга, эксплуатации и обслуживания серверов."
			echo "Официальная документация по созданию сайта: https://nezha.wiki/guide/dashboard.html."
			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
				check_docker_app_ip
			fi
			echo ""
			echo "------------------------"
			echo "1. Используйте"
			echo "------------------------"
			echo "0. Вернуться в предыдущее меню"
			echo "------------------------"
			read -e -p "Введите свой выбор:" choice

			case $choice in
				1)
					check_disk_space 1
					install unzip jq
					install_docker
					curl -sL ${gh_proxy}raw.githubusercontent.com/nezhahq/scripts/refs/heads/main/install.sh -o nezha.sh && chmod +x nezha.sh && ./nezha.sh
					local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
					check_docker_app_ip
					;;

				*)
					break
					;;

			esac
			break_end
		done
		  ;;

	  8|qb|QB)

		local app_id="8"
		local docker_name="qbittorrent"
		local docker_img="lscr.io/linuxserver/qbittorrent:latest"
		local docker_port=8081

		docker_rum() {

			docker run -d \
			  --name=qbittorrent \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e WEBUI_PORT=${docker_port} \
			  -e TORRENTING_PORT=56881 \
			  -p ${docker_port}:${docker_port} \
			  -p 56881:56881 \
			  -p 56881:56881/udp \
			  -v /home/docker/qbittorrent/config:/config \
			  -v /home/docker/qbittorrent/downloads:/downloads \
			  --restart=always \
			  lscr.io/linuxserver/qbittorrent:latest

		}

		local docker_describe="qbittorrent офлайн-сервис магнитной загрузки BT"
		local docker_url="Официальный сайт: https://hub.docker.com/r/linuxserver/qbittorrent."
		local docker_use="sleep 3"
		local docker_passwd="docker logs qbittorrent"
		local app_size="1"
		docker_app

		  ;;

	  9|mail)
		send_stats "Построить почтовое отделение"
		clear
		install telnet
		local app_id="9"
		local docker_name=“mailserver”
		while true; do
			check_docker_app
			check_docker_image_update $docker_name

			clear
			echo -e "почтовая служба$check_docker $update_status"
			echo "poste.io — это почтовый сервер с открытым исходным кодом,"
			echo "Видео-знакомство: https://www.bilibili.com/video/BV1wv421C71t?t=0.1"

			echo ""
			echo "Обнаружение порта"
			port=25
			timeout=3
			if echo "quit" | timeout $timeout telnet smtp.qq.com $port | grep 'Connected'; then
			  echo -e "${gl_lv}порт$portДоступно в настоящее время${gl_bai}"
			else
			  echo -e "${gl_hong}порт$portВ настоящее время недоступен${gl_bai}"
			fi
			echo ""

			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				yuming=$(cat /home/docker/mail.txt)
				echo "Адрес посещения:"
				echo "https://$yuming"
			fi

			echo "------------------------"
			echo "1. Установить 2. Обновить 3. Удалить"
			echo "------------------------"
			echo "0. Вернуться в предыдущее меню"
			echo "------------------------"
			read -e -p "Введите свой выбор:" choice

			case $choice in
				1)
					setup_docker_dir
					check_disk_space 2 /home/docker
					read -e -p "Пожалуйста, укажите доменное имя электронной почты, например mail.yuming.com:" yuming
					mkdir -p /home/docker
					echo "$yuming" > /home/docker/mail.txt
					echo "------------------------"
					ip_address
					echo "Сначала проанализируйте эти записи DNS"
					echo "A           mail            $ipv4_address"
					echo "CNAME       imap            $yuming"
					echo "CNAME       pop             $yuming"
					echo "CNAME       smtp            $yuming"
					echo "MX          @               $yuming"
					echo "TXT         @               v=spf1 mx ~all"
					echo "TXT         ?               ?"
					echo ""
					echo "------------------------"
					echo "Нажмите любую клавишу, чтобы продолжить..."
					read -n 1 -s -r -p ""

					install jq
					install_docker

					docker run \
						--net=host \
						-e TZ=Europe/Prague \
						-v /home/docker/mail:/data \
						--name "mailserver" \
						-h "$yuming" \
						--restart=always \
						-d analogic/poste.io


					add_app_id

					clear
					echo "poste.io установлен."
					echo "------------------------"
					echo "Вы можете получить доступ к poste.io, используя следующий адрес:"
					echo "https://$yuming"
					echo ""

					;;

				2)
					docker rm -f mailserver
					docker rmi -f analogic/poste.i
					yuming=$(cat /home/docker/mail.txt)
					docker run \
						--net=host \
						-e TZ=Europe/Prague \
						-v /home/docker/mail:/data \
						--name "mailserver" \
						-h "$yuming" \
						--restart=always \
						-d analogic/poste.i


					add_app_id

					clear
					echo "poste.io установлен."
					echo "------------------------"
					echo "Вы можете получить доступ к poste.io, используя следующий адрес:"
					echo "https://$yuming"
					echo ""
					;;
				3)
					docker rm -f mailserver
					docker rmi -f analogic/poste.io
					rm /home/docker/mail.txt
					rm -rf /home/docker/mail

					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					echo "Приложение удалено"
					;;

				*)
					break
					;;

			esac
			break_end
		done

		  ;;

	  10|rocketchat)

		local app_id="10"
		local app_name="Чат-система Rocket.Chat"
		local app_text="Rocket.Chat — это платформа командного общения с открытым исходным кодом, которая поддерживает чат в реальном времени, аудио- и видеозвонки, обмен файлами и другие функции."
		local app_url="Официальное представление: https://www.rocket.chat/"
		local docker_name="rocketchat"
		local docker_port="3897"
		local app_size="2"

		docker_app_install() {
			docker run --name db -d --restart=always \
				-v /home/docker/mongo/dump:/dump \
				mongo:latest --replSet rs5 --oplogSize 256
			sleep 1
			docker exec db mongosh --eval "printjson(rs.initiate())"
			sleep 5
			docker run --name rocketchat --restart=always -p ${docker_port}:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat

			clear
			ip_address
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			docker rm -f rocketchat
			docker rmi -f rocket.chat:latest
			docker run --name rocketchat --restart=always -p ${docker_port}:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat
			clear
			ip_address
			echo "rocket.chat установлен"
			check_docker_app_ip
		}

		docker_app_uninstall() {
			docker rm -f rocketchat
			docker rmi -f rocket.chat
			docker rm -f db
			docker rmi -f mongo:latest
			rm -rf /home/docker/mongo
			echo "Приложение удалено"
		}

		docker_app_plus
		  ;;



	  11|zentao)
		local app_id="11"
		local docker_name="zentao-server"
		local docker_img="idoop/zentao:latest"
		local docker_port=82


		docker_rum() {


			docker run -d -p ${docker_port}:80 \
			  -e ADMINER_USER="root" -e ADMINER_PASSWD="password" \
			  -e BIND_ADDRESS="false" \
			  -v /home/docker/zentao-server/:/opt/zbox/ \
			  --add-host smtp.exmail.qq.com:163.177.90.125 \
			  --name zentao-server \
			  --restart=always \
			  idoop/zentao:latest


		}

		local docker_describe="ZenTao — универсальное программное обеспечение для управления проектами."
		local docker_url="Официальный сайт: https://www.zentao.net/"
		local docker_use="echo \"Начальное имя пользователя: admin\""
		local docker_passwd="echo \"Начальный пароль: 123456\""
		local app_size="2"
		docker_app

		  ;;

	  12|qinglong)
		local app_id="12"
		local docker_name="qinglong"
		local docker_img="whyour/qinglong:latest"
		local docker_port=5700

		docker_rum() {


			docker run -d \
			  -v /home/docker/qinglong/data:/ql/data \
			  -p ${docker_port}:5700 \
			  --name qinglong \
			  --hostname qinglong \
			  --restart=always \
			  whyour/qinglong:latest


		}

		local docker_describe="Qinglong Panel — платформа для управления запланированными задачами"
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/whyour/qinglong"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;
	  13|cloudreve)

		local app_id="13"
		local app_name="сетевой диск Cloudreve"
		local app_text="Cloudreve — сетевая дисковая система, поддерживающая несколько облачных хранилищ"
		local app_url="Видео-знакомство: https://www.bilibili.com/video/BV13F4m1c7h7?t=0.1"
		local docker_name="cloudreve"
		local docker_port="5212"
		local app_size="2"

		docker_app_install() {
			cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
			curl -o /home/docker/cloud/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/cloudreve-docker-compose.yml
			sed -i "s/5212:5212/${docker_port}:5212/g" /home/docker/cloud/docker-compose.yml
			cd /home/docker/cloud/
			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/cloud/ && docker compose down --rmi all
			cd /home/docker/cloud/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/cloud/ && docker compose down --rmi all
			rm -rf /home/docker/cloud
			echo "Приложение удалено"
		}

		docker_app_plus
		  ;;

	  14|easyimage)
		local app_id="14"
		local docker_name="easyimage"
		local docker_img="ddsderek/easyimage:latest"
		local docker_port=8014
		docker_rum() {

			docker run -d \
			  --name easyimage \
			  -p ${docker_port}:80 \
			  -e TZ=Asia/Shanghai \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -v /home/docker/easyimage/config:/app/web/config \
			  -v /home/docker/easyimage/i:/app/web/i \
			  --restart=always \
			  ddsderek/easyimage:latest

		}

		local docker_describe="Простая кровать для рисования - это простая программа для рисования."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/icret/EasyImages2.0"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  15|emby)
		local app_id="15"
		local docker_name="emby"
		local docker_img="linuxserver/emby:latest"
		local docker_port=8015

		docker_rum() {

			docker run -d --name=emby --restart=always \
				-v /home/docker/emby/config:/config \
				-v /home/docker/emby/share1:/mnt/share1 \
				-v /home/docker/emby/share2:/mnt/share2 \
				-v /mnt/notify:/mnt/notify \
				-p ${docker_port}:8096 \
				-e UID=1000 -e GID=100 -e GIDLIST=100 \
				linuxserver/emby:latest

		}


		local docker_describe="Emby — это программное обеспечение медиасервера с архитектурой «главный-подчиненный», которое можно использовать для организации видео и аудио на сервере и потоковой передачи аудио и видео на клиентские устройства."
		local docker_url="Официальный сайт: https://emby.media/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  16|looking)
		local app_id="16"
		local docker_name="looking-glass"
		local docker_img="wikihostinc/looking-glass-server"
		local docker_port=8016


		docker_rum() {

			docker run -d --name looking-glass --restart=always -p ${docker_port}:80 wikihostinc/looking-glass-server

		}

		local docker_describe="Панель измерения скорости Speedtest — это инструмент для проверки скорости сети VPS с множеством функций тестирования, а также может отслеживать входящий и исходящий трафик VPS в режиме реального времени."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/wikihost-opensource/als"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;
	  17|adguardhome)

		local app_id="17"
		local docker_name="adguardhome"
		local docker_img="adguard/adguardhome"
		local docker_port=8017

		docker_rum() {

			docker run -d \
				--name adguardhome \
				-v /home/docker/adguardhome/work:/opt/adguardhome/work \
				-v /home/docker/adguardhome/conf:/opt/adguardhome/conf \
				-p 53:53/tcp \
				-p 53:53/udp \
				-p ${docker_port}:3000/tcp \
				--restart=always \
				adguard/adguardhome


		}


		local docker_describe="AdGuardHome — это общесетевое программное обеспечение для блокировки рекламы и отслеживания, которое в будущем станет больше, чем просто DNS-сервером."
		local docker_url="Официальный сайт: https://hub.docker.com/r/adguard/adguardhome."
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  18|onlyoffice)

		local app_id="18"
		local docker_name="onlyoffice"
		local docker_img="onlyoffice/documentserver"
		local docker_port=8018

		docker_rum() {

			docker run -d -p ${docker_port}:80 \
				--restart=always \
				--name onlyoffice \
				-v /home/docker/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
				-v /home/docker/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
				 onlyoffice/documentserver


		}

		local docker_describe="onlyoffice — это мощный онлайн-офисный инструмент с открытым исходным кодом!"
		local docker_url="Официальный сайт: https://www.onlyoffice.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app

		  ;;

	  19|safeline)
		send_stats "Постройте громовой бассейн"

		local app_id="19"
		local docker_name=safeline-mgt
		local docker_port=9443
		while true; do
			check_docker_app
			clear
			echo -e "Служба громового бассейна$check_docker"
			echo "Leichi — это программная панель брандмауэра сайта WAF, разработанная Changting Technology, которая может перевернуть сайт для автоматической защиты."
			echo "Видео-знакомство: https://www.bilibili.com/video/BV1mZ421T74c?t=0.1"
			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				check_docker_app_ip
			fi
			echo ""

			echo "------------------------"
			echo "1. Установить 2. Обновить 3. Сбросить пароль 4. Удалить"
			echo "------------------------"
			echo "0. Вернуться в предыдущее меню"
			echo "------------------------"
			read -e -p "Введите свой выбор:" choice

			case $choice in
				1)
					install_docker
					check_disk_space 5
					bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"

					add_app_id
					clear
					echo "Панель Leichi WAF установлена."
					check_docker_app_ip
					docker exec safeline-mgt resetadmin

					;;

				2)
					bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/upgrade.sh)"
					docker rmi $(docker images | grep "safeline" | grep "none" | awk '{print $3}')
					echo ""

					add_app_id
					clear
					echo "Панель Leichi WAF обновлена."
					check_docker_app_ip
					;;
				3)
					docker exec safeline-mgt resetadmin
					;;
				4)
					cd /data/safeline
					docker compose down --rmi all

					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					echo "Если вы находитесь в каталоге установки по умолчанию, проект уже удален. Если вы настраиваете каталог установки, вам нужно перейти в каталог установки и выполнить его самостоятельно:"
					echo "docker compose down && docker compose down --rmi all"
					;;
				*)
					break
					;;

			esac
			break_end
		done

		  ;;

	  20|portainer)
		local app_id="20"
		local docker_name="portainer"
		local docker_img="portainer/portainer"
		local docker_port=8020

		docker_rum() {

			docker run -d \
				--name portainer \
				-p ${docker_port}:9000 \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v /home/docker/portainer:/data \
				--restart=always \
				portainer/portainer

		}


		local docker_describe="portainer — легкая панель управления Docker-контейнером."
		local docker_url="Официальный сайт: https://www.porttainer.io/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  21|vscode)
		local app_id="21"
		local docker_name="vscode-web"
		local docker_img="codercom/code-server"
		local docker_port=8021


		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/vscode-web:/home/coder/.local/share/code-server --name vscode-web --restart=always codercom/code-server

		}


		local docker_describe="VScode — мощный онлайн-инструмент для написания кода."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/coder/code-server"
		local docker_use="sleep 3"
		local docker_passwd="docker exec vscode-web cat /home/coder/.config/code-server/config.yaml"
		local app_size="1"
		docker_app
		  ;;


	  22|uptime-kuma)
		local app_id="22"
		local docker_name="uptime-kuma"
		local docker_img="louislam/uptime-kuma:latest"
		local docker_port=8022


		docker_rum() {

			docker run -d \
				--name=uptime-kuma \
				-p ${docker_port}:3001 \
				-v /home/docker/uptime-kuma/uptime-kuma-data:/app/data \
				--restart=always \
				louislam/uptime-kuma:latest

		}


		local docker_describe="Uptime Kuma Простой в использовании автономный инструмент мониторинга"
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/louislam/uptime-kuma"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  23|memos)
		local app_id="23"
		local docker_name="memos"
		local docker_img="neosmemo/memos:stable"
		local docker_port=8023

		docker_rum() {

			docker run -d --name memos -p ${docker_port}:5230 -v /home/docker/memos:/var/opt/memos --restart=always neosmemo/memos:stable

		}

		local docker_describe="Memos — это легкий автономный центр заметок."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/usememos/memos"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  24|webtop)
		local app_id="24"
		local docker_name="webtop"
		local docker_img="lscr.io/linuxserver/webtop:latest"
		local docker_port=8024

		docker_rum() {

			read -e -p "Установите имя пользователя для входа:" admin
			read -e -p "Установите пароль пользователя для входа:" admin_password
			docker run -d \
			  --name=webtop \
			  --security-opt seccomp=unconfined \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e SUBFOLDER=/ \
			  -e TITLE=Webtop \
			  -e CUSTOM_USER=${admin} \
			  -e PASSWORD=${admin_password} \
			  -e LC_ALL=zh_CN.UTF-8 \
			  -e DOCKER_MODS=linuxserver/mods:universal-package-install \
			  -e INSTALL_PACKAGES=font-noto-cjk \
			  -p ${docker_port}:3000 \
			  -v /home/docker/webtop/data:/config \
			  -v /var/run/docker.sock:/var/run/docker.sock \
			  --shm-size="1gb" \
			  --restart=always \
			  lscr.io/linuxserver/webtop:latest

		}


		local docker_describe="webtop основан на китайской версии контейнера Alpine. Если доступ к IP-адресу невозможен, добавьте доменное имя для доступа."
		local docker_url="Официальный сайт: https://docs.linuxserver.io/images/docker-webtop/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  25|nextcloud)
		local app_id="25"
		local docker_name="nextcloud"
		local docker_img="nextcloud:latest"
		local docker_port=8025
		local rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)

		docker_rum() {

			docker run -d --name nextcloud --restart=always -p ${docker_port}:80 -v /home/docker/nextcloud:/var/www/html -e NEXTCLOUD_ADMIN_USER=nextcloud -e NEXTCLOUD_ADMIN_PASSWORD=$rootpasswd nextcloud

		}

		local docker_describe="Nextcloud — это самая популярная платформа для совместной работы с локальным контентом, которую вы можете загрузить, с более чем 400 000 развертываний."
		local docker_url="Официальный сайт: https://nextcloud.com/"
		local docker_use="echo \"Учетная запись: nextcloud Пароль:$rootpasswd\""
		local docker_passwd=""
		local app_size="3"
		docker_app
		  ;;

	  26|qd)
		local app_id="26"
		local docker_name="qd"
		local docker_img="qdtoday/qd:latest"
		local docker_port=8026

		docker_rum() {

			docker run -d --name qd -p ${docker_port}:80 -v /home/docker/qd/config:/usr/src/app/config qdtoday/qd

		}

		local docker_describe="QD-Today — это платформа автоматического выполнения запланированных задач HTTP-запросов."
		local docker_url="Официальный сайт: https://qd-today.github.io/qd/zh_CN/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  27|dockge)
		local app_id="27"
		local docker_name="dockge"
		local docker_img="louislam/dockge:latest"
		local docker_port=8027

		docker_rum() {

			docker run -d --name dockge --restart=always -p ${docker_port}:5001 -v /var/run/docker.sock:/var/run/docker.sock -v /home/docker/dockge/data:/app/data -v  /home/docker/dockge/stacks:/home/docker/dockge/stacks -e DOCKGE_STACKS_DIR=/home/docker/dockge/stacks louislam/dockge

		}

		local docker_describe="Dockge — это визуальная панель управления контейнерами, созданная с помощью Docker."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/louislam/dockge"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  28|speedtest)
		local app_id="28"
		local docker_name="speedtest"
		local docker_img="ghcr.io/librespeed/speedtest"
		local docker_port=8028

		docker_rum() {

			docker run -d -p ${docker_port}:8080 --name speedtest --restart=always ghcr.io/librespeed/speedtest

		}

		local docker_describe="librespeed — это легкий инструмент для тестирования скорости, реализованный на Javascript, который можно использовать «из коробки»."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/librespeed/speedtest"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  29|searxng)
		local app_id="29"
		local docker_name="searxng"
		local docker_img="searxng/searxng"
		local docker_port=8029

		docker_rum() {

			docker run -d \
			  --name searxng \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -v "/home/docker/searxng:/etc/searxng" \
			  searxng/searxng

		}

		local docker_describe="searchxng — частный и частный сайт поисковой системы."
		local docker_url="Официальный сайт: https://hub.docker.com/r/alandoyle/searxng."
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  30|photoprism)
		local app_id="30"
		local docker_name="photoprism"
		local docker_img="photoprism/photoprism:latest"
		local docker_port=8030
		local rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)

		docker_rum() {

			docker run -d \
				--name photoprism \
				--restart=always \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				-p ${docker_port}:2342 \
				-e PHOTOPRISM_UPLOAD_NSFW="true" \
				-e PHOTOPRISM_ADMIN_PASSWORD="$rootpasswd" \
				-v /home/docker/photoprism/storage:/photoprism/storage \
				-v /home/docker/photoprism/Pictures:/photoprism/originals \
				photoprism/photoprism

		}


		local docker_describe="Photoprism — очень мощная система частных фотоальбомов."
		local docker_url="Официальный сайт: https://www.photoprism.app/"
		local docker_use="echo \"Учетная запись: Пароль администратора:$rootpasswd\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  31|s-pdf)
		local app_id="31"
		local docker_name="s-pdf"
		local docker_img="frooodle/s-pdf:latest"
		local docker_port=8031

		docker_rum() {

			docker run -d \
				--name s-pdf \
				--restart=always \
				 -p ${docker_port}:8080 \
				 -v /home/docker/s-pdf/trainingData:/usr/share/tesseract-ocr/5/tessdata \
				 -v /home/docker/s-pdf/extraConfigs:/configs \
				 -v /home/docker/s-pdf/logs:/logs \
				 -e DOCKER_ENABLE_SECURITY=false \
				 frooodle/s-pdf:latest
		}

		local docker_describe="Это мощный локально размещенный веб-инструмент для работы с PDF-файлами с использованием Docker, который позволяет выполнять различные операции с PDF-файлами, такие как разделение, преобразование, реорганизация, добавление изображений, поворот, сжатие и т. д."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/Stirling-Tools/Stirling-PDF"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  32|drawio)
		local app_id="32"
		local docker_name="drawio"
		local docker_img="jgraph/drawio"
		local docker_port=8032

		docker_rum() {

			docker run -d --restart=always --name drawio -p ${docker_port}:8080 -v /home/docker/drawio:/var/lib/drawio jgraph/drawio

		}


		local docker_describe="Это мощное программное обеспечение для построения графиков. Вы можете рисовать интеллектуальные карты, топологические диаграммы и блок-схемы."
		local docker_url="Официальный сайт: https://www.drawio.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  33|sun-panel)
		local app_id="33"
		local docker_name="sun-panel"
		local docker_img="hslr/sun-panel"
		local docker_port=8033

		docker_rum() {

			docker run -d --restart=always -p ${docker_port}:3002 \
				-v /home/docker/sun-panel/conf:/app/conf \
				-v /home/docker/sun-panel/uploads:/app/uploads \
				-v /home/docker/sun-panel/database:/app/database \
				--name sun-panel \
				hslr/sun-panel

		}

		local docker_describe="Сервер Sun-Panel, навигационная панель NAS, домашняя страница, домашняя страница браузера"
		local docker_url="Официальный сайт: https://doc.sun-panel.top/zh_cn/"
		local docker_use="echo \"Учётная запись: admin@sun.cc Пароль: 12345678\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  34|pingvin-share)
		local app_id="34"
		local docker_name="pingvin-share"
		local docker_img="stonith404/pingvin-share"
		local docker_port=8034

		docker_rum() {

			docker run -d \
				--name pingvin-share \
				--restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/pingvin-share/data:/opt/app/backend/data \
				stonith404/pingvin-share
		}

		local docker_describe="Pingvin Share — это самостоятельная платформа для обмена файлами и альтернатива WeTransfer."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/stonith404/pingvin-share"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  35|moments)
		local app_id="35"
		local docker_name="moments"
		local docker_img="kingwrcy/moments:latest"
		local docker_port=8035

		docker_rum() {

			docker run -d --restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/moments/data:/app/data \
				-v /etc/localtime:/etc/localtime:ro \
				-v /etc/timezone:/etc/timezone:ro \
				--name moments \
				kingwrcy/moments:latest
		}


		local docker_describe="Минималистские моменты, высокая имитация моментов WeChat, запишите свою замечательную жизнь"
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/kingwrcy/moments?tab=readme-ov-file"
		local docker_use="echo \"Учётная запись: Пароль администратора: a123456\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;



	  36|lobe-chat)
		local app_id="36"
		local docker_name="lobe-chat"
		local docker_img="lobehub/lobe-chat:latest"
		local docker_port=8036

		docker_rum() {

			docker run -d -p ${docker_port}:3210 \
				--name lobe-chat \
				--restart=always \
				lobehub/lobe-chat
		}

		local docker_describe="LobeChat объединяет основные крупные модели искусственного интеллекта на рынке: ChatGPT/Claude/Gemini/Groq/Ollama."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/lobehub/lobe-chat"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  37|myip)
		local app_id="37"
		local docker_name="myip"
		local docker_img="jason5ng32/myip:latest"
		local docker_port=8037

		docker_rum() {

			docker run -d -p ${docker_port}:18966 --name myip jason5ng32/myip:latest

		}


		local docker_describe="Это многофункциональный набор IP-инструментов, который позволяет вам просматривать собственную информацию об IP и подключениях и отображать ее с помощью веб-панели."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/jason5ng32/MyIP/blob/main/README_ZH.md"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  38|xiaoya)
		send_stats "Семейное ведро Сяоя"
		clear
		install_docker
		check_disk_space 1
		bash -c "$(curl --insecure -fsSL https://ddsrem.com/xiaoya_install.sh)"
		  ;;

	  39|bililive)

		if [ ! -d /home/docker/bililive-go/ ]; then
			mkdir -p /home/docker/bililive-go/ > /dev/null 2>&1
			wget -O /home/docker/bililive-go/config.yml ${gh_proxy}raw.githubusercontent.com/hr3lxphr6j/bililive-go/master/config.yml > /dev/null 2>&1
		fi

		local app_id="39"
		local docker_name="bililive-go"
		local docker_img="chigusa/bililive-go"
		local docker_port=8039

		docker_rum() {

			docker run --restart=always --name bililive-go -v /home/docker/bililive-go/config.yml:/etc/bililive-go/config.yml -v /home/docker/bililive-go/Videos:/srv/bililive -p ${docker_port}:8080 -d chigusa/bililive-go

		}

		local docker_describe="Bililive-go — это инструмент для записи прямых трансляций, который поддерживает несколько платформ прямых трансляций."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/hr3lxphr6j/bililive-go"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  40|webssh)
		local app_id="40"
		local docker_name="webssh"
		local docker_img="jrohy/webssh"
		local docker_port=8040
		docker_rum() {
			docker run -d -p ${docker_port}:5032 --restart=always --name webssh -e TZ=Asia/Shanghai jrohy/webssh
		}

		local docker_describe="Простой онлайн-инструмент для подключения по SSH и инструмент по sftp"
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/Jrohy/webssh"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  41|haozi|acepanel)

		local app_id="41"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="Оригинальная панель мыши AcePanel"
		local panelurl="Официальный адрес:${gh_proxy}github.com/acepanel/panel"

		panel_app_install() {
			cd ~
			bash <(curl -sSLm 10 https://dl.acepanel.net/helper.sh)
		}

		panel_app_manage() {
			acepanel help
		}

		panel_app_uninstall() {
			cd ~
			bash <(curl -sSLm 10 https://dl.acepanel.net/helper.sh)

		}

		install_panel

		  ;;


	  42|nexterm)
		local app_id="42"
		local docker_name="nexterm"
		local docker_img="germannewsmaker/nexterm:latest"
		local docker_port=8042

		docker_rum() {

			ENCRYPTION_KEY=$(openssl rand -hex 32)
			docker run -d \
			  --name nexterm \
			  -e ENCRYPTION_KEY=${ENCRYPTION_KEY} \
			  -p ${docker_port}:6989 \
			  -v /home/docker/nexterm:/app/data \
			  --restart=always \
			  germannewsmaker/nexterm:latest

		}

		local docker_describe="nexterm — мощный онлайн-инструмент для подключения SSH/VNC/RDP."
		local docker_url="Официальный сайт: введение:${gh_proxy}github.com/gnmyt/Nexterm"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  43|hbbs)
		local app_id="43"
		local docker_name="hbbs"
		local docker_img="rustdesk/rustdesk-server"
		local docker_port=0000

		docker_rum() {

			docker run --name hbbs -v /home/docker/hbbs/data:/root -td --net=host --restart=always rustdesk/rustdesk-server hbbs

		}


		local docker_describe="Удаленный рабочий стол (сервер) Rustdesk с открытым исходным кодом похож на собственный частный сервер Sunflower."
		local docker_url="Официальный сайт: https://rustdesk.com/zh-cn/"
		local docker_use="docker logs hbbs"
		local docker_passwd="echo \"Запишите свой IP-адрес и ключ, которые будут использоваться в клиенте удаленного рабочего стола. Перейдите к опции 44, чтобы установить реле!\""
		local app_size="1"
		docker_app
		  ;;

	  44|hbbr)
		local app_id="44"
		local docker_name="hbbr"
		local docker_img="rustdesk/rustdesk-server"
		local docker_port=0000

		docker_rum() {

			docker run --name hbbr -v /home/docker/hbbr/data:/root -td --net=host --restart=always rustdesk/rustdesk-server hbbr

		}

		local docker_describe="Удаленный рабочий стол (реле) с открытым исходным кодом Rustdesk похож на собственный частный сервер Sunflower."
		local docker_url="Официальный сайт: https://rustdesk.com/zh-cn/"
		local docker_use="echo \"Перейдите на официальный сайт, чтобы загрузить клиент удаленного рабочего стола: https://rustdesk.com/zh-cn/\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  45|registry)
		local app_id="45"
		local docker_name="registry"
		local docker_img="registry:2"
		local docker_port=8045

		docker_rum() {

			docker run -d \
				-p ${docker_port}:5000 \
				--name registry \
				-v /home/docker/registry:/var/lib/registry \
				-e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
				--restart=always \
				registry:2

		}

		local docker_describe="Docker Registry — сервис для хранения и распространения образов Docker."
		local docker_url="Официальный сайт: https://hub.docker.com/_/registry."
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  46|ghproxy)
		local app_id="46"
		local docker_name="ghproxy"
		local docker_img="wjqserver/ghproxy:latest"
		local docker_port=8046

		docker_rum() {

			docker run -d --name ghproxy --restart=always -p ${docker_port}:8080 -v /home/docker/ghproxy/config:/data/ghproxy/config wjqserver/ghproxy:latest

		}

		local docker_describe="GHProxy, реализованный с использованием Go, в некоторых областях используется для ускорения извлечения репозиториев Github."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/WJQSERVER-STUDIO/ghproxy"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  47|prometheus|grafana)

		local app_id="47"
		local app_name="Мониторинг Прометея"
		local app_text="Система мониторинга корпоративного уровня Prometheus+Grafana"
		local app_url="Официальный сайт: https://prometheus.io"
		local docker_name="grafana"
		local docker_port="8047"
		local app_size="2"

		docker_app_install() {
			prometheus_install
			clear
			ip_address
			echo "Установка завершена"
			check_docker_app_ip
			echo "Исходное имя пользователя и пароль: admin."
		}

		docker_app_update() {
			docker rm -f node-exporter prometheus grafana
			docker rmi -f prom/node-exporter
			docker rmi -f prom/prometheus:latest
			docker rmi -f grafana/grafana:latest
			docker_app_install
		}

		docker_app_uninstall() {
			docker rm -f node-exporter prometheus grafana
			docker rmi -f prom/node-exporter
			docker rmi -f prom/prometheus:latest
			docker rmi -f grafana/grafana:latest

			rm -rf /home/docker/monitoring
			echo "Приложение удалено"
		}

		docker_app_plus
		  ;;

	  48|node-exporter)
		local app_id="48"
		local docker_name="node-exporter"
		local docker_img="prom/node-exporter"
		local docker_port=8048

		docker_rum() {

			docker run -d \
				--name=node-exporter \
				-p ${docker_port}:9100 \
				--restart=always \
				prom/node-exporter


		}

		local docker_describe="Это компонент сбора данных хоста Prometheus, разверните его на отслеживаемом хосте."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/prometheus/node_exporter"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  49|cadvisor)
		local app_id="49"
		local docker_name="cadvisor"
		local docker_img="gcr.io/cadvisor/cadvisor:latest"
		local docker_port=8049

		docker_rum() {

			docker run -d \
				--name=cadvisor \
				--restart=always \
				-p ${docker_port}:8080 \
				--volume=/:/rootfs:ro \
				--volume=/var/run:/var/run:rw \
				--volume=/sys:/sys:ro \
				--volume=/var/lib/docker/:/var/lib/docker:ro \
				gcr.io/cadvisor/cadvisor:latest \
				-housekeeping_interval=10s \
				-docker_only=true

		}

		local docker_describe="Это компонент сбора данных контейнера Prometheus, разверните его на отслеживаемом хосте."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/google/cadvisor"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  50|changedetection)
		local app_id="50"
		local docker_name="changedetection"
		local docker_img="dgtlmoon/changedetection.io:latest"
		local docker_port=8050

		docker_rum() {

			docker run -d --restart=always -p ${docker_port}:5000 \
				-v /home/docker/datastore:/datastore \
				--name changedetection dgtlmoon/changedetection.io:latest

		}

		local docker_describe="Это небольшой инструмент для обнаружения изменений на сайте, мониторинга пополнения и уведомления."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/dgtlmoon/changedetection.io"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  51|pve)
		clear
		send_stats "PVE открытая цыпочка"
		check_disk_space 1
		curl -L ${gh_proxy}raw.githubusercontent.com/oneclickvirt/pve/main/scripts/install_pve.sh -o install_pve.sh && chmod +x install_pve.sh && bash install_pve.sh
		  ;;


	  52|dpanel)
		local app_id="52"
		local docker_name="dpanel"
		local docker_img="dpanel/dpanel:lite"
		local docker_port=8052

		docker_rum() {

			docker run -d --name dpanel --restart=always \
				-p ${docker_port}:8080 -e APP_NAME=dpanel \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v /home/docker/dpanel:/dpanel \
				dpanel/dpanel:lite

		}

		local docker_describe="Система визуальных панелей Docker обеспечивает полные функции управления докером."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/donknap/dpanel"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  53|llama3)
		local app_id="53"
		local docker_name="ollama"
		local docker_img="ghcr.io/open-webui/open-webui:ollama"
		local docker_port=8053

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/ollama:/root/.ollama -v /home/docker/ollama/open-webui:/app/backend/data --name ollama --restart=always ghcr.io/open-webui/open-webui:ollama

		}

		local docker_describe="OpenWebUI — это платформа веб-страниц с большой языковой моделью, подключенная к новой большой языковой модели llama3."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use="docker exec ollama ollama run llama3.2:1b"
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;

	  54|amh)

		local app_id="54"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="Панель АМГ"
		local panelurl="Официальный адрес: https://amh.sh/index.htm?amh"

		panel_app_install() {
			cd ~
			wget https://dl.amh.sh/amh.sh && bash amh.sh
		}

		panel_app_manage() {
			panel_app_install
		}

		panel_app_uninstall() {
			panel_app_install
		}

		install_panel
		  ;;


	  55|frps)
		frps_panel
		  ;;

	  56|frpc)
		frpc_panel
		  ;;

	  57|deepseek)
		local app_id="57"
		local docker_name="ollama"
		local docker_img="ghcr.io/open-webui/open-webui:ollama"
		local docker_port=8053

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/ollama:/root/.ollama -v /home/docker/ollama/open-webui:/app/backend/data --name ollama --restart=always ghcr.io/open-webui/open-webui:ollama

		}

		local docker_describe="OpenWebUI — это платформа веб-страниц с большой языковой моделью, подключенная к новой большой языковой модели DeepSeek R1."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use="docker exec ollama ollama run deepseek-r1:1.5b"
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;


	  58|dify)
		local app_id="58"
		local app_name="База знаний Dify"
		local app_text="Это платформа разработки приложений с открытым исходным кодом для модели большого языка (LLM). Самостоятельно размещаемые данные обучения для генерации ИИ"
		local app_url="Официальный сайт: https://docs.dify.ai/zh-hans"
		local docker_name="docker-nginx-1"
		local docker_port="8058"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/langgenius/dify.git && cd dify/docker && cp .env.example .env
			sed -i "s/^EXPOSE_NGINX_PORT=.*/EXPOSE_NGINX_PORT=${docker_port}/; s/^EXPOSE_NGINX_SSL_PORT=.*/EXPOSE_NGINX_SSL_PORT=8858/" /home/docker/dify/docker/.env

			docker compose up -d

			chown -R 1001:1001 /home/docker/dify/docker/volumes/app/storage
			chmod -R 755 /home/docker/dify/docker/volumes/app/storage
			docker compose down
			docker compose up -d

			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/dify/docker/ && docker compose down --rmi all
			cd  /home/docker/dify/
			git pull ${gh_proxy}github.com/langgenius/dify.git main > /dev/null 2>&1
			sed -i 's/^EXPOSE_NGINX_PORT=.*/EXPOSE_NGINX_PORT=8058/; s/^EXPOSE_NGINX_SSL_PORT=.*/EXPOSE_NGINX_SSL_PORT=8858/' /home/docker/dify/docker/.env
			cd  /home/docker/dify/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/dify/docker/ && docker compose down --rmi all
			rm -rf /home/docker/dify
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;

	  59|new-api)
		local app_id="59"
		local app_name="NewAPI"
		local app_text="Новое поколение шлюза для крупных моделей и системы управления активами с использованием искусственного интеллекта."
		local app_url="Официальный сайт:${gh_https_url}github.com/Calcium-Ion/new-api"
		local docker_name="new-api"
		local docker_port="8059"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/Calcium-Ion/new-api.git && cd new-api

			sed -i -e "s/- \"3000:3000\"/- \"${docker_port}:3000\"/g" \
				   -e 's/container_name: redis/container_name: redis-new-api/g' \
				   -e 's/container_name: mysql/container_name: mysql-new-api/g' \
				   docker-compose.yml


			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/new-api/ && docker compose down --rmi all
			cd  /home/docker/new-api/

			git pull ${gh_proxy}github.com/Calcium-Ion/new-api.git main > /dev/null 2>&1
			sed -i -e "s/- \"3000:3000\"/- \"${docker_port}:3000\"/g" \
				   -e 's/container_name: redis/container_name: redis-new-api/g' \
				   -e 's/container_name: mysql/container_name: mysql-new-api/g' \
				   docker-compose.yml

			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip

		}

		docker_app_uninstall() {
			cd  /home/docker/new-api/ && docker compose down --rmi all
			rm -rf /home/docker/new-api
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;


	  60|jms)

		local app_id="60"
		local app_name="JumpServer — бастионная машина с открытым исходным кодом"
		local app_text="Это инструмент управления привилегированным доступом (PAM) с открытым исходным кодом. Эта программа занимает порт 80 и не поддерживает добавление доменных имен для доступа."
		local app_url="Официальное введение:${gh_https_url}github.com/jumpserver/jumpserver"
		local docker_name="jms_web"
		local docker_port="80"
		local app_size="2"

		docker_app_install() {
			curl -sSL ${gh_proxy}github.com/jumpserver/jumpserver/releases/latest/download/quick_start.sh | bash
			clear
			echo "Установка завершена"
			check_docker_app_ip
			echo "Первоначальное имя пользователя: admin"
			echo "Начальный пароль: ChangeMe"
		}


		docker_app_update() {
			cd /opt/jumpserver-installer*/
			./jmsctl.sh upgrade
			echo "Приложение обновлено"
		}


		docker_app_uninstall() {
			cd /opt/jumpserver-installer*/
			./jmsctl.sh uninstall
			cd /opt
			rm -rf jumpserver-installer*/
			rm -rf jumpserver
			echo "Приложение удалено"
		}

		docker_app_plus
		  ;;

	  61|libretranslate)
		local app_id="61"
		local docker_name="libretranslate"
		local docker_img="libretranslate/libretranslate:latest"
		local docker_port=8061

		docker_rum() {

			docker run -d \
				-p ${docker_port}:5000 \
				--name libretranslate \
				libretranslate/libretranslate \
				--load-only ko,zt,zh,en,ja,pt,es,fr,de,ru

		}

		local docker_describe="Бесплатный API машинного перевода с открытым исходным кодом, полностью размещаемый самостоятельно, а его механизм перевода основан на библиотеке Argos Translate с открытым исходным кодом."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/LibreTranslate/LibreTranslate"
		local docker_use=""
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;



	  62|ragflow)
		local app_id="62"
		local app_name="База знаний RAGFlow"
		local app_text="Движок RAG (Retrival Augmented Generation) с открытым исходным кодом, основанный на глубоком понимании документов."
		local app_url="Официальный сайт:${gh_https_url}github.com/infiniflow/ragflow"
		local docker_name="ragflow-server"
		local docker_port="8062"
		local app_size="8"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/infiniflow/ragflow.git && cd ragflow/docker
			sed -i "s/- 80:80/- ${docker_port}:80/; /- 443:443/d" docker-compose.yml
			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/ragflow/docker/ && docker compose down --rmi all
			cd  /home/docker/ragflow/
			git pull ${gh_proxy}github.com/infiniflow/ragflow.git main > /dev/null 2>&1
			cd  /home/docker/ragflow/docker/
			sed -i "s/- 80:80/- ${docker_port}:80/; /- 443:443/d" docker-compose.yml
			docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/ragflow/docker/ && docker compose down --rmi all
			rm -rf /home/docker/ragflow
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;


	  63|open-webui)
		local app_id="63"
		local docker_name="open-webui"
		local docker_img="ghcr.io/open-webui/open-webui:main"
		local docker_port=8063

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/open-webui:/app/backend/data --name open-webui --restart=always ghcr.io/open-webui/open-webui:main

		}

		local docker_describe="OpenWebUI — это платформа веб-страниц с большой языковой моделью. Официальная упрощенная версия поддерживает доступ через API ко всем основным моделям."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use=""
		local docker_passwd=""
		local app_size="3"
		docker_app
		  ;;

	  64|it-tools)
		local app_id="64"
		local docker_name="it-tools"
		local docker_img="corentinth/it-tools:latest"
		local docker_port=8064

		docker_rum() {
			docker run -d --name it-tools --restart=always -p ${docker_port}:80 corentinth/it-tools:latest
		}

		local docker_describe="Очень полезный инструмент для разработчиков и ИТ-специалистов."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/CorentinTh/it-tools"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  65|n8n)
		local app_id="65"
		local docker_name="n8n"
		local docker_img="docker.n8n.io/n8nio/n8n"
		local docker_port=8065

		docker_rum() {

			add_yuming
			mkdir -p /home/docker/n8n
			chmod -R 777 /home/docker/n8n

			docker run -d --name n8n \
			  --restart=always \
			  -p ${docker_port}:5678 \
			  -v /home/docker/n8n:/home/node/.n8n \
			  -e N8N_HOST=${yuming} \
			  -e N8N_PORT=5678 \
			  -e N8N_PROTOCOL=https \
			  -e WEBHOOK_URL=https://${yuming}/ \
			  docker.n8n.io/n8nio/n8n

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

		}

		local docker_describe="Это мощная платформа автоматизированного рабочего процесса."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/n8n-io/n8n"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  66|yt)
		yt_menu_pro
		  ;;


	  67|ddns)
		local app_id="67"
		local docker_name="ddns-go"
		local docker_img="jeessy/ddns-go"
		local docker_port=8067

		docker_rum() {
			docker run -d \
				--name ddns-go \
				--restart=always \
				-p ${docker_port}:9876 \
				-v /home/docker/ddns-go:/root \
				jeessy/ddns-go

		}

		local docker_describe="Автоматически обновляйте свой общедоступный IP-адрес (IPv4/IPv6) для основных поставщиков услуг DNS в режиме реального времени, чтобы добиться динамического разрешения доменных имен."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/jeessy2/ddns-go"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  68|allinssl)
		local app_id="68"
		local docker_name="allinssl"
		local docker_img="allinssl/allinssl:latest"
		local docker_port=8068

		docker_rum() {
			docker run -d --name allinssl -p ${docker_port}:8888 -v /home/docker/allinssl/data:/www/allinssl/data -e ALLINSSL_USER=allinssl -e ALLINSSL_PWD=allinssldocker -e ALLINSSL_URL=allinssl allinssl/allinssl:latest
		}

		local docker_describe="Бесплатная платформа управления SSL-сертификатами с открытым исходным кодом"
		local docker_url="Официальный сайт: https://allinssl.com"
		local docker_use="echo \"Вход в систему безопасности: /allinssl\""
		local docker_passwd="echo \"Имя пользователя: allinssl Пароль: allinssldocker\""
		local app_size="1"
		docker_app
		  ;;


	  69|sftpgo)
		local app_id="69"
		local docker_name="sftpgo"
		local docker_img="drakkan/sftpgo:latest"
		local docker_port=8069

		docker_rum() {

			mkdir -p /home/docker/sftpgo/data
			mkdir -p /home/docker/sftpgo/config
			chown -R 1000:1000 /home/docker/sftpgo

			docker run -d \
			  --name sftpgo \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -p 22022:2022 \
			  --mount type=bind,source=/home/docker/sftpgo/data,target=/srv/sftpgo \
			  --mount type=bind,source=/home/docker/sftpgo/config,target=/var/lib/sftpgo \
			  drakkan/sftpgo:latest

		}

		local docker_describe="Бесплатный инструмент с открытым исходным кодом в любое время и в любом месте SFTP FTP WebDAV инструмент для передачи файлов"
		local docker_url="Официальный сайт: https://sftpgo.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  70|astrbot)
		local app_id="70"
		local docker_name="astrbot"
		local docker_img="soulter/astrbot:latest"
		local docker_port=8070

		docker_rum() {

			mkdir -p /home/docker/astrbot/data

			docker run -d \
			  -p ${docker_port}:6185 \
			  -p 6195:6195 \
			  -p 6196:6196 \
			  -p 6199:6199 \
			  -p 11451:11451 \
			  -v /home/docker/astrbot/data:/AstrBot/data \
			  --restart=always \
			  --name astrbot \
			  soulter/astrbot:latest

		}

		local docker_describe="Платформа чат-ботов с открытым исходным кодом для искусственного интеллекта, поддерживающая доступ WeChat, QQ и TG к крупным моделям искусственного интеллекта."
		local docker_url="Официальный сайт: https://astrbot.app/"
		local docker_use="echo \"Имя пользователя: astrbot Пароль: astrbot\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  71|navidrome)
		local app_id="71"
		local docker_name="navidrome"
		local docker_img="deluan/navidrome:latest"
		local docker_port=8071

		docker_rum() {

			docker run -d \
			  --name navidrome \
			  --restart=always \
			  --user $(id -u):$(id -g) \
			  -v /home/docker/navidrome/music:/music \
			  -v /home/docker/navidrome/data:/data \
			  -p ${docker_port}:4533 \
			  -e ND_LOGLEVEL=info \
			  deluan/navidrome:latest

		}

		local docker_describe="Легкий и высокопроизводительный сервер потоковой передачи музыки."
		local docker_url="Официальный сайт: https://www.navidrome.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  72|bitwarden)

		local app_id="72"
		local docker_name="bitwarden"
		local docker_img="vaultwarden/server"
		local docker_port=8072

		docker_rum() {

			docker run -d \
				--name bitwarden \
				--restart=always \
				-p ${docker_port}:80 \
				-v /home/docker/bitwarden/data:/data \
				vaultwarden/server

		}

		local docker_describe="Менеджер паролей, который дает вам контроль над вашими данными"
		local docker_url="Официальный сайт: https://bitwarden.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app


		  ;;



	  73|libretv)

		local app_id="73"
		local docker_name="libretv"
		local docker_img="bestzwei/libretv:latest"
		local docker_port=8073

		docker_rum() {

			read -e -p "Установите пароль для входа в LibreTV:" app_passwd

			docker run -d \
			  --name libretv \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -e PASSWORD=${app_passwd} \
			  bestzwei/libretv:latest

		}

		local docker_describe="Бесплатная онлайн-платформа для поиска и просмотра видео"
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/LibreSpark/LibreTV"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  74|moontv)

		local app_id="74"

		local app_name="MoonTV: частное кино и телевидение"
		local app_text="Бесплатная онлайн-платформа для поиска и просмотра видео"
		local app_url="Видео введение:${gh_https_url}github.com/MoonTechLab/LunaTV"
		local docker_name="moontv-core"
		local docker_port="8074"
		local app_size="2"

		docker_app_install() {
			read -e -p "Установите имя пользователя для входа:" admin
			read -e -p "Установите пароль пользователя для входа:" admin_password
			read -e -p "Введите код авторизации:" shouquanma


			mkdir -p /home/docker/moontv
			mkdir -p /home/docker/moontv/config
			mkdir -p /home/docker/moontv/data
			cd /home/docker/moontv

			curl -o /home/docker/moontv/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/moontv-docker-compose.yml
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/moontv/docker-compose.yml
			sed -i "s|admin_password|${admin_password}|g" /home/docker/moontv/docker-compose.yml
			sed -i "s|admin|${admin}|g" /home/docker/moontv/docker-compose.yml
			sed -i "s|shouquanma|${shouquanma}|g" /home/docker/moontv/docker-compose.yml
			cd /home/docker/moontv/
			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/moontv/ && docker compose down --rmi all
			cd /home/docker/moontv/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/moontv/ && docker compose down --rmi all
			rm -rf /home/docker/moontv
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;


	  75|melody)

		local app_id="75"
		local docker_name="melody"
		local docker_img="foamzou/melody:latest"
		local docker_port=8075

		docker_rum() {

			docker run -d \
			  --name melody \
			  --restart=always \
			  -p ${docker_port}:5566 \
			  -v /home/docker/melody/.profile:/app/backend/.profile \
			  foamzou/melody:latest


		}

		local docker_describe="Ваш музыкальный мастер, созданный, чтобы помочь вам лучше управлять своей музыкой."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/foamzou/melody"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app


		  ;;


	  76|dosgame)

		local app_id="76"
		local docker_name="dosgame"
		local docker_img="oldiy/dosgame-web-docker:latest"
		local docker_port=8076

		docker_rum() {
			docker run -d \
				--name dosgame \
				--restart=always \
				-p ${docker_port}:262 \
				oldiy/dosgame-web-docker:latest

		}

		local docker_describe="Это китайский веб-сайт с коллекцией игр для DOS."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/rwv/chinese-dos-games"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app


		  ;;

	  77|xunlei)

		local app_id="77"
		local docker_name="xunlei"
		local docker_img="cnk3x/xunlei"
		local docker_port=8077

		docker_rum() {

			read -e -p "Установите имя пользователя для входа:" app_use
			read -e -p "Установить пароль для входа:" app_passwd

			docker run -d \
			  --name xunlei \
			  --restart=always \
			  --privileged \
			  -e XL_DASHBOARD_USERNAME=${app_use} \
			  -e XL_DASHBOARD_PASSWORD=${app_passwd} \
			  -v /home/docker/xunlei/data:/xunlei/data \
			  -v /home/docker/xunlei/downloads:/xunlei/downloads \
			  -p ${docker_port}:2345 \
			  cnk3x/xunlei

		}

		local docker_describe="Xunlei, ваш автономный высокоскоростной магнитный инструмент загрузки BT"
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/cnk3x/xunlei"
		local docker_use="echo \"Войдите в Xunlei со своего мобильного телефона и введите код приглашения. Код приглашения: Xunlei Niutong\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  78|PandaWiki)

		local app_id="78"
		local app_name="PandaWiki"
		local app_text="PandaWiki — это интеллектуальная система управления документами с открытым исходным кодом, основанная на больших моделях искусственного интеллекта. Настоятельно рекомендуется не настраивать развертывание портов."
		local app_url="Официальное введение:${gh_https_url}github.com/chaitin/PandaWiki"
		local docker_name="panda-wiki-nginx"
		local docker_port="2443"
		local app_size="2"

		docker_app_install() {
			bash -c "$(curl -fsSLk https://release.baizhi.cloud/panda-wiki/manager.sh)"
		}

		docker_app_update() {
			docker_app_install
		}


		docker_app_uninstall() {
			docker_app_install
		}

		docker_app_plus
		  ;;



	  79|beszel)

		local app_id="79"
		local docker_name="beszel"
		local docker_img="henrygd/beszel"
		local docker_port=8079

		docker_rum() {

			mkdir -p /home/docker/beszel && \
			docker run -d \
			  --name beszel \
			  --restart=always \
			  -v /home/docker/beszel:/beszel_data \
			  -p ${docker_port}:8090 \
			  henrygd/beszel

		}

		local docker_describe="Beszel — легкий и простой в использовании инструмент для мониторинга серверов."
		local docker_url="Официальный сайт: https://beszel.dev/zh/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  80|linkwarden)

		  local app_id="80"
		  local app_name="управление закладками Linkwarden"
		  local app_text="Автономная платформа управления закладками с открытым исходным кодом, которая поддерживает тегирование, поиск и совместную работу в команде."
		  local app_url="Официальный сайт: https://linkwarden.app/"
		  local docker_name="linkwarden-linkwarden-1"
		  local docker_port="8080"
		  local app_size="3"

		  docker_app_install() {
			  install git openssl
			  mkdir -p /home/docker/linkwarden && cd /home/docker/linkwarden

			  # Загрузите официальные файлы docker-compose и env.
			  curl -O ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/docker-compose.yml
			  curl -L ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/.env.sample -o ".env"

			  # Генерируйте случайные ключи и пароли
			  local ADMIN_EMAIL="admin@example.com"
			  local ADMIN_PASSWORD=$(openssl rand -hex 8)

			  sed -i "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=http://localhost:${docker_port}/api/v1/auth|g" .env
			  sed -i "s|^NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=$(openssl rand -hex 32)|g" .env
			  sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(openssl rand -hex 16)|g" .env
			  sed -i "s|^MEILI_MASTER_KEY=.*|MEILI_MASTER_KEY=$(openssl rand -hex 32)|g" .env

			  # Добавьте информацию об учетной записи администратора
			  echo "ADMIN_EMAIL=${ADMIN_EMAIL}" >> .env
			  echo "ADMIN_PASSWORD=${ADMIN_PASSWORD}" >> .env

			  sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/linkwarden/docker-compose.yml

			  # Запустить контейнер
			  docker compose up -d

			  clear
			  echo "Установка завершена"
		  	  check_docker_app_ip

		  }

		  docker_app_update() {
			  cd /home/docker/linkwarden && docker compose down --rmi all
			  curl -O ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/docker-compose.yml
			  curl -L ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/.env.sample -o ".env.new"

			  # Сохранить исходные переменные
			  source .env
			  mv .env.new .env
			  echo "NEXTAUTH_URL=$NEXTAUTH_URL" >> .env
			  echo "NEXTAUTH_SECRET=$NEXTAUTH_SECRET" >> .env
			  echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
			  echo "MEILI_MASTER_KEY=$MEILI_MASTER_KEY" >> .env
			  echo "ADMIN_EMAIL=$ADMIN_EMAIL" >> .env
			  echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> .env
			  sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/linkwarden/docker-compose.yml

			  docker compose up -d
		  }

		  docker_app_uninstall() {
			  cd /home/docker/linkwarden && docker compose down --rmi all
			  rm -rf /home/docker/linkwarden
			  echo "Приложение удалено"
		  }

		  docker_app_plus

		  ;;



	  81|jitsi)
		  local app_id="81"
		  local app_name="Видеоконференция JitsiMeet"
		  local app_text="Решение для безопасных видеоконференций с открытым исходным кодом, которое поддерживает онлайн-конференции с участием нескольких человек, совместное использование экрана и зашифрованную связь."
		  local app_url="Официальный сайт: https://jitsi.org/"
		  local docker_name="jitsi"
		  local docker_port="8081"
		  local app_size="3"

		  docker_app_install() {

			  add_yuming
			  mkdir -p /home/docker/jitsi && cd /home/docker/jitsi
			  wget $(wget -q -O - https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep zip | cut -d\" -f4)
			  unzip "$(ls -t | head -n 1)"
			  cd "$(ls -dt */ | head -n 1)"
			  cp env.example .env
			  ./gen-passwords.sh
			  mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
			  sed -i "s|^HTTP_PORT=.*|HTTP_PORT=${docker_port}|" .env
			  sed -i "s|^#PUBLIC_URL=https://meet.example.com:\${HTTPS_PORT}|PUBLIC_URL=https://$yuming:443|" .env
			  docker compose up -d

			  ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			  block_container_port "$docker_name" "$ipv4_address"

		  }

		  docker_app_update() {
			  cd /home/docker/jitsi
			  cd "$(ls -dt */ | head -n 1)"
			  docker compose down --rmi all
			  docker compose up -d

		  }

		  docker_app_uninstall() {
			  cd /home/docker/jitsi
			  cd "$(ls -dt */ | head -n 1)"
			  docker compose down --rmi all
			  rm -rf /home/docker/jitsi
			  echo "Приложение удалено"
		  }

		  docker_app_plus

		  ;;



	  82|gpt-load)

		local app_id="82"
		local docker_name="gpt-load"
		local docker_img="tbphp/gpt-load:latest"
		local docker_port=8082

		docker_rum() {

			read -e -p "настраивать${docker_name}Ключ входа (sk — комбинация букв и цифр, начинающаяся с), например: sk-159kejilionyyds163:" app_passwd

			mkdir -p /home/docker/gpt-load && \
			docker run -d --name gpt-load \
				-p ${docker_port}:3001 \
				-e AUTH_KEY=${app_passwd} \
				-v "/home/docker/gpt-load/data":/app/data \
				tbphp/gpt-load:latest

		}

		local docker_describe="Высокопроизводительный прозрачный прокси-сервис с AI-интерфейсом"
		local docker_url="Официальный сайт: https://www.gpt-load.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  83|komari)

		local app_id="83"
		local docker_name="komari"
		local docker_img="ghcr.io/komari-monitor/komari:latest"
		local docker_port=8083

		docker_rum() {

			mkdir -p /home/docker/komari && \
			docker run -d \
			  --name komari \
			  -p ${docker_port}:25774 \
			  -v /home/docker/komari:/app/data \
			  -e ADMIN_USERNAME=admin \
			  -e ADMIN_PASSWORD=1212156 \
			  -e TZ=Asia/Shanghai \
			  --restart=always \
			  ghcr.io/komari-monitor/komari:latest

		}

		local docker_describe="Легкий инструмент мониторинга локального сервера."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/komari-monitor/komari/tree/main"
		local docker_use="echo \"Учётная запись по умолчанию: admin Пароль по умолчанию: 1212156\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  84|wallos)

		local app_id="84"
		local docker_name="wallos"
		local docker_img="bellamy/wallos:latest"
		local docker_port=8084

		docker_rum() {

			mkdir -p /home/docker/wallos && \
			docker run -d --name wallos \
			  -v /home/docker/wallos/db:/var/www/html/db \
			  -v /home/docker/wallos/logos:/var/www/html/images/uploads/logos \
			  -e TZ=UTC \
			  -p ${docker_port}:80 \
			  --restart=always \
			  bellamy/wallos:latest

		}

		local docker_describe="Персональный трекер подписки с открытым исходным кодом для управления финансами"
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/ellite/Wallos"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  85|immich)

		  local app_id="85"
		  local app_name="immich фото-видео-менеджер"
		  local app_text="Высокопроизводительное автономное решение для управления фотографиями и видео."
		  local app_url="Официальный сайт: введение:${gh_https_url}github.com/immich-app/immich"
		  local docker_name="immich_server"
		  local docker_port="8085"
		  local app_size="3"

		  docker_app_install() {
			  install git openssl wget
			  mkdir -p /home/docker/${docker_name} && cd /home/docker/${docker_name}

			  wget -O docker-compose.yml ${gh_proxy}github.com/immich-app/immich/releases/latest/download/docker-compose.yml
			  wget -O .env ${gh_proxy}github.com/immich-app/immich/releases/latest/download/example.env
			  sed -i "s/2283:2283/${docker_port}:2283/g" /home/docker/${docker_name}/docker-compose.yml

			  docker compose up -d

			  clear
			  echo "Установка завершена"
		  	  check_docker_app_ip

		  }

		  docker_app_update() {
				cd /home/docker/${docker_name} && docker compose down --rmi all
				docker_app_install
		  }

		  docker_app_uninstall() {
			  cd /home/docker/${docker_name} && docker compose down --rmi all
			  rm -rf /home/docker/${docker_name}
			  echo "Приложение удалено"
		  }

		  docker_app_plus


		  ;;


	  86|jellyfin)

		local app_id="86"
		local docker_name="jellyfin"
		local docker_img="jellyfin/jellyfin"
		local docker_port=8086

		docker_rum() {

			mkdir -p /home/docker/jellyfin/media
			chmod -R 777 /home/docker/jellyfin

			docker run -d \
			  --name jellyfin \
			  --user root \
			  --volume /home/docker/jellyfin/config:/config \
			  --volume /home/docker/jellyfin/cache:/cache \
			  --mount type=bind,source=/home/docker/jellyfin/media,target=/media \
			  -p ${docker_port}:8096 \
			  -p 7359:7359/udp \
			  --restart=always \
			  jellyfin/jellyfin


		}

		local docker_describe="Это программное обеспечение медиасервера с открытым исходным кодом."
		local docker_url="Официальный сайт: https://jellyfin.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  87|synctv)

		local app_id="87"
		local docker_name="synctv"
		local docker_img="synctvorg/synctv"
		local docker_port=8087

		docker_rum() {

			docker run -d \
				--name synctv \
				-v /home/docker/synctv:/root/.synctv \
				-p ${docker_port}:8080 \
				--restart=always \
				synctvorg/synctv

		}

		local docker_describe="Программа для совместного просмотра фильмов и прямых трансляций удаленно. Он обеспечивает одновременный просмотр, прямую трансляцию, чат и другие функции."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/synctv-org/synctv"
		local docker_use="echo \"Исходная учетная запись и пароль: root. Пожалуйста, измените пароль для входа вовремя после входа в систему\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  88|owncast)

		local app_id="88"
		local docker_name="owncast"
		local docker_img="owncast/owncast:latest"
		local docker_port=8088

		docker_rum() {

			docker run -d \
				--name owncast \
				-p ${docker_port}:8080 \
				-p 1935:1935 \
				-v /home/docker/owncast/data:/app/data \
				--restart=always \
				owncast/owncast:latest


		}

		local docker_describe="Бесплатная самодельная платформа прямых трансляций с открытым исходным кодом"
		local docker_url="Официальный сайт: https://owncast.online"
		local docker_use="echo \"За адресом доступа следует /admin для доступа к странице администратора\""
		local docker_passwd="echo \"Исходная учетная запись: admin Начальный пароль: abc123 Пожалуйста, своевременно измените пароль для входа в систему после входа в систему\""
		local app_size="1"
		docker_app

		  ;;



	  89|file-code-box)

		local app_id="89"
		local docker_name="file-code-box"
		local docker_img="lanol/filecodebox:latest"
		local docker_port=8089

		docker_rum() {

			docker run -d \
			  --name file-code-box \
			  -p ${docker_port}:12345 \
			  -v /home/docker/file-code-box/data:/app/data \
			  --restart=always \
			  lanol/filecodebox:latest

		}

		local docker_describe="Делитесь текстами и файлами с анонимными паролями и получайте файлы, например экспресс-доставку."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/vastsa/FileCodeBox"
		local docker_use="echo \"За адресом доступа следует /#/admin для доступа к странице администратора\""
		local docker_passwd="echo \"Пароль администратора: FileCodeBox2023\""
		local app_size="1"
		docker_app

		  ;;




	  90|matrix)

		local app_id="90"
		local docker_name="matrix"
		local docker_img="matrixdotorg/synapse:latest"
		local docker_port=8090

		docker_rum() {

			add_yuming

			if [ ! -d /home/docker/matrix/data ]; then
				docker run --rm \
				  -v /home/docker/matrix/data:/data \
				  -e SYNAPSE_SERVER_NAME=${yuming} \
				  -e SYNAPSE_REPORT_STATS=yes \
				  --name matrix \
				  matrixdotorg/synapse:latest generate
			fi

			docker run -d \
			  --name matrix \
			  -v /home/docker/matrix/data:/data \
			  -p ${docker_port}:8008 \
			  --restart=always \
			  matrixdotorg/synapse:latest

			echo "Создайте первоначального пользователя или администратора. Пожалуйста, установите следующие имя пользователя и пароль и укажите, являетесь ли вы администратором."
			docker exec -it matrix register_new_matrix_user \
			  http://localhost:8008 \
			  -c /data/homeserver.yaml

			sed -i '/^enable_registration:/d' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^# vim:ft=yaml/i enable_registration: true' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^enable_registration_without_verification:/d' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^# vim:ft=yaml/i enable_registration_without_verification: true' /home/docker/matrix/data/homeserver.yaml

			docker restart matrix

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

		}

		local docker_describe="Matrix — децентрализованный протокол чата."
		local docker_url="Официальный сайт: https://matrix.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  91|gitea)

		local app_id="91"

		local app_name="хранилище частного кода gitea"
		local app_text="Бесплатная платформа хостинга кода нового поколения, обеспечивающая возможности, близкие к GitHub."
		local app_url="Видео введение:${gh_https_url}github.com/go-gitea/gitea"
		local docker_name="gitea"
		local docker_port="8091"
		local app_size="2"

		docker_app_install() {

			mkdir -p /home/docker/gitea
			mkdir -p /home/docker/gitea/gitea
			mkdir -p /home/docker/gitea/data
			mkdir -p /home/docker/gitea/postgres
			cd /home/docker/gitea

			curl -o /home/docker/gitea/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/gitea-docker-compose.yml
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/gitea/docker-compose.yml
			cd /home/docker/gitea/
			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/gitea/ && docker compose down --rmi all
			cd /home/docker/gitea/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/gitea/ && docker compose down --rmi all
			rm -rf /home/docker/gitea
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;




	  92|filebrowser)

		local app_id="92"
		local docker_name="filebrowser"
		local docker_img="hurlenko/filebrowser"
		local docker_port=8092

		docker_rum() {

			docker run -d \
				--name filebrowser \
				--restart=always \
				-p ${docker_port}:8080 \
				-v /home/docker/filebrowser/data:/data \
				-v /home/docker/filebrowser/config:/config \
				-e FB_BASEURL=/filebrowser \
				hurlenko/filebrowser

		}

		local docker_describe="Это веб-файловый менеджер."
		local docker_url="Официальный сайт: https://filebrowser.org/"
		local docker_use="docker logs filebrowser"
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	93|dufs)

		local app_id="93"
		local docker_name="dufs"
		local docker_img="sigoden/dufs"
		local docker_port=8093

		docker_rum() {

			docker run -d \
			  --name ${docker_name} \
			  --restart=always \
			  -v /home/docker/${docker_name}:/data \
			  -p ${docker_port}:5000 \
			  ${docker_img} /data -A

		}

		local docker_describe="Минималистичный статический файловый сервер, поддерживает загрузку и загрузку."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/sigoden/dufs"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;

	94|gopeed)

		local app_id="94"
		local docker_name="gopeed"
		local docker_img="liwei2633/gopeed"
		local docker_port=8094

		docker_rum() {

			read -e -p "Установите имя пользователя для входа:" app_use
			read -e -p "Установить пароль для входа:" app_passwd

			docker run -d \
			  --name ${docker_name} \
			  --restart=always \
			  -v /home/docker/${docker_name}/downloads:/app/Downloads \
			  -v /home/docker/${docker_name}/storage:/app/storage \
			  -p ${docker_port}:9999 \
			  ${docker_img} -u ${app_use} -p ${app_passwd}

		}

		local docker_describe="Инструмент распределенной высокоскоростной загрузки, поддерживающий несколько протоколов."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/GopeedLab/gopeed"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;



	  95|paperless)

		local app_id="95"

		local app_name="платформа управления безбумажными документами"
		local app_text="Система электронного документооборота с открытым исходным кодом, ее основная цель — оцифровка и управление вашими бумажными документами."
		local app_url="Видео-знакомство: https://docs.paperless-ngx.com/"
		local docker_name="paperless-webserver-1"
		local docker_port="8095"
		local app_size="2"

		docker_app_install() {

			mkdir -p /home/docker/paperless
			mkdir -p /home/docker/paperless/export
			mkdir -p /home/docker/paperless/consume
			cd /home/docker/paperless

			curl -o /home/docker/paperless/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/main/docker/compose/docker-compose.postgres-tika.yml
			curl -o /home/docker/paperless/docker-compose.env ${gh_proxy}raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/main/docker/compose/.env

			sed -i "s/8000:8000/${docker_port}:8000/g" /home/docker/paperless/docker-compose.yml
			cd /home/docker/paperless
			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/paperless/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/paperless/ && docker compose down --rmi all
			rm -rf /home/docker/paperless
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;



	  96|2fauth)

		local app_id="96"

		local app_name="Самостоятельный двухэтапный аутентификатор 2FAuth"
		local app_text="Самостоятельный инструмент управления учетными записями двухфакторной аутентификации (2FA) и генерации проверочного кода."
		local app_url="Официальный сайт:${gh_https_url}github.com/Bubka/2FAuth"
		local docker_name="2fauth"
		local docker_port="8096"
		local app_size="1"

		docker_app_install() {

			add_yuming

			mkdir -p /home/docker/2fauth
			mkdir -p /home/docker/2fauth/data
			chmod -R 777 /home/docker/2fauth/
			cd /home/docker/2fauth

			curl -o /home/docker/2fauth/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/2fauth-docker-compose.yml

			sed -i "s/8000:8000/${docker_port}:8000/g" /home/docker/2fauth/docker-compose.yml
			sed -i "s/yuming.com/${yuming}/g" /home/docker/2fauth/docker-compose.yml
			cd /home/docker/2fauth
			docker compose up -d

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/2fauth/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/2fauth/ && docker compose down --rmi all
			rm -rf /home/docker/2fauth
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;



	97|wgs)

		local app_id="97"
		local docker_name="wireguard"
		local docker_img="lscr.io/linuxserver/wireguard:latest"
		local docker_port=8097

		docker_rum() {

		read -e -p  "Введите количество клиентов в сети (по умолчанию 5):" COUNT
		COUNT=${COUNT:-5}
		read -e -p  "Пожалуйста, введите сегмент сети WireGuard (по умолчанию 10.13.13.0):" NETWORK
		NETWORK=${NETWORK:-10.13.13.0}

		PEERS=$(seq -f "wg%02g" 1 "$COUNT" | paste -sd,)

		ip link delete wg0 &>/dev/null

		ip_address
		docker run -d \
		  --name=wireguard \
		  --network host \
		  --cap-add=NET_ADMIN \
		  --cap-add=SYS_MODULE \
		  -e PUID=1000 \
		  -e PGID=1000 \
		  -e TZ=Etc/UTC \
		  -e SERVERURL=${ipv4_address} \
		  -e SERVERPORT=51820 \
		  -e PEERS=${PEERS} \
		  -e INTERNAL_SUBNET=${NETWORK} \
		  -e ALLOWEDIPS=${NETWORK}/24 \
		  -e PERSISTENTKEEPALIVE_PEERS=all \
		  -e LOG_CONFS=true \
		  -v /home/docker/wireguard/config:/config \
		  -v /lib/modules:/lib/modules \
		  --restart=always \
		  lscr.io/linuxserver/wireguard:latest


		sleep 3

		docker exec wireguard sh -c "
		f='/config/wg_confs/wg0.conf'
		sed -i 's/51820/${docker_port}/g' \$f
		"

		docker exec wireguard sh -c "
		for d in /config/peer_*; do
		  sed -i 's/51820/${docker_port}/g' \$d/*.conf
		done
		"

		docker exec wireguard sh -c '
		for d in /config/peer_*; do
		  sed -i "/^DNS/d" "$d"/*.conf
		done
		'

		docker exec wireguard sh -c '
		for d in /config/peer_*; do
		  for f in "$d"/*.conf; do
			grep -q "^PersistentKeepalive" "$f" || \
			sed -i "/^AllowedIPs/ a PersistentKeepalive = 25" "$f"
		  done
		done
		'

		docker exec wireguard bash -c '
		for d in /config/peer_*; do
		  cd "$d" || continue
		  conf_file=$(ls *.conf)
		  base_name="${conf_file%.conf}"
		  qrencode -o "$base_name.png" < "$conf_file"
		done
		'

		docker restart wireguard

		sleep 2
		echo
		echo -e "${gl_huang}Все конфигурации QR-кода клиента:${gl_bai}"
		docker exec wireguard bash -c 'for i in $(ls /config | grep peer_ | sed "s/peer_//"); do echo "--- $i ---"; /app/show-peer $i; done'
		sleep 2
		echo
		echo -e "${gl_huang}Все коды конфигурации клиента:${gl_bai}"
		docker exec wireguard sh -c 'for d in /config/peer_*; do echo "# $(basename $d) "; cat $d/*.conf; echo; done'
		sleep 2
		echo -e "${gl_lv}${COUNT}Настройте все выходы для каждого клиента. Способ использования следующий:${gl_bai}"
		echo -e "${gl_lv}1. Загрузите приложение wg на свой мобильный телефон и отсканируйте приведенный выше QR-код, чтобы быстро подключиться к Интернету.${gl_bai}"
		echo -e "${gl_lv}2. Загрузите клиент для Windows и скопируйте код конфигурации для подключения к сети.${gl_bai}"
		echo -e "${gl_lv}3. Используйте сценарий для развертывания клиента WG в Linux и скопируйте код конфигурации для подключения к сети.${gl_bai}"
		echo -e "${gl_lv}Официальный метод загрузки клиента: https://www.wireguard.com/install/${gl_bai}"
		break_end

		}

		local docker_describe="Современные высокопроизводительные инструменты виртуальных частных сетей"
		local docker_url="Официальный сайт: https://www.wireguard.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	98|wgc)

		local app_id="98"
		local docker_name="wireguardc"
		local docker_img="kjlion/wireguard:alpine"
		local docker_port=51820

		docker_rum() {

			mkdir -p /home/docker/wireguard/config/

			local CONFIG_FILE="/home/docker/wireguard/config/wg0.conf"

			# Создать каталог, если он не существует
			mkdir -p "$(dirname "$CONFIG_FILE")"

			echo "Вставьте конфигурацию клиента и дважды нажмите Enter, чтобы сохранить:"

			# инициализировать переменные
			input=""
			empty_line_count=0

			# Чтение ввода пользователя построчно
			while IFS= read -r line; do
				if [[ -z "$line" ]]; then
					((empty_line_count++))
					if [[ $empty_line_count -ge 2 ]]; then
						break
					fi
				else
					empty_line_count=0
					input+="$line"$'\n'
				fi
			done

			# Записать файл конфигурации
			echo "$input" > "$CONFIG_FILE"

			echo "Конфигурация клиента сохранена в$CONFIG_FILE"

			ip link delete wg0 &>/dev/null

			docker run -d \
			  --name wireguardc \
			  --network host \
			  --cap-add NET_ADMIN \
			  --cap-add SYS_MODULE \
			  -v /home/docker/wireguard/config:/config \
			  -v /lib/modules:/lib/modules:ro \
			  --restart=always \
			  kjlion/wireguard:alpine

			sleep 3

			docker logs wireguardc

		break_end

		}

		local docker_describe="Современные высокопроизводительные инструменты виртуальных частных сетей"
		local docker_url="Официальный сайт: https://www.wireguard.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	  99|dsm)

		local app_id="99"

		local app_name="виртуальная машина Synology dsm"
		local app_text="Виртуальный DSM в контейнере Docker"
		local app_url="Официальный сайт:${gh_https_url}github.com/vdsm/virtual-dsm"
		local docker_name="dsm"
		local docker_port="8099"
		local app_size="16"

		docker_app_install() {

			read -e -p "Установите количество ядер процессора (по умолчанию 2):" CPU_CORES
			local CPU_CORES=${CPU_CORES:-2}

			read -e -p "Установить размер памяти (по умолчанию 4G):" RAM_SIZE
			local RAM_SIZE=${RAM_SIZE:-4}

			mkdir -p /home/docker/dsm
			mkdir -p /home/docker/dsm/dev
			chmod -R 777 /home/docker/dsm/
			cd /home/docker/dsm

			curl -o /home/docker/dsm/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/dsm-docker-compose.yml

			sed -i "s/5000:5000/${docker_port}:5000/g" /home/docker/dsm/docker-compose.yml
			sed -i "s|CPU_CORES: "2"|CPU_CORES: "${CPU_CORES}"|g" /home/docker/dsm/docker-compose.yml
			sed -i "s|RAM_SIZE: "2G"|RAM_SIZE: "${RAM_SIZE}G"|g" /home/docker/dsm/docker-compose.yml
			cd /home/docker/dsm
			docker compose up -d

			clear
			echo "Установка завершена"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/dsm/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/dsm/ && docker compose down --rmi all
			rm -rf /home/docker/dsm
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;



	100|syncthing)

		local app_id="100"
		local docker_name="syncthing"
		local docker_img="syncthing/syncthing:latest"
		local docker_port=8100

		docker_rum() {
			docker run -d \
			  --name=syncthing \
			  --hostname=my-syncthing \
			  --restart=always \
			  -p ${docker_port}:8384 \
			  -p 22000:22000/tcp \
			  -p 22000:22000/udp \
			  -p 21027:21027/udp \
			  -v /home/docker/syncthing:/var/syncthing \
			  syncthing/syncthing:latest
		}

		local docker_describe="Инструмент одноранговой синхронизации файлов с открытым исходным кодом, похожий на Dropbox и Resilio Sync, но полностью децентрализованный."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/syncthing/syncthing"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	  101|moneyprinterturbo)
		local app_id="101"
		local app_name="Инструмент для создания видео с использованием искусственного интеллекта"
		local app_text="MoneyPrinterTurbo — это инструмент, который использует большие модели искусственного интеллекта для синтеза коротких видеороликов высокой четкости."
		local app_url="Официальный сайт:${gh_https_url}github.com/harry0703/MoneyPrinterTurbo"
		local docker_name="moneyprinterturbo"
		local docker_port="8101"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/harry0703/MoneyPrinterTurbo.git && cd MoneyPrinterTurbo/
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/MoneyPrinterTurbo/docker-compose.yml

			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose down --rmi all
			cd  /home/docker/MoneyPrinterTurbo/

			git pull ${gh_proxy}github.com/harry0703/MoneyPrinterTurbo.git main > /dev/null 2>&1
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/MoneyPrinterTurbo/docker-compose.yml
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose down --rmi all
			rm -rf /home/docker/MoneyPrinterTurbo
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;



	  102|vocechat)

		local app_id="102"
		local docker_name="vocechat-server"
		local docker_img="privoce/vocechat-server:latest"
		local docker_port=8102

		docker_rum() {

			docker run -d --restart=always \
			  -p ${docker_port}:3000 \
			  --name vocechat-server \
			  -v /home/docker/vocechat/data:/home/vocechat-server/data \
			  privoce/vocechat-server:latest

		}

		local docker_describe="Это персональный облачный чат-сервис в социальных сетях, который поддерживает независимое развертывание."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/Privoce/vocechat-web"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  103|umami)
		local app_id="103"
		local app_name="Инструмент статистики сайта Umami"
		local app_text="Легкий и безопасный для конфиденциальности инструмент анализа веб-сайтов с открытым исходным кодом, аналогичный Google Analytics."
		local app_url="Официальный сайт:${gh_https_url}github.com/umami-software/umami"
		local docker_name="umami-umami-1"
		local docker_port="8103"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/umami-software/umami.git && cd umami
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/umami/docker-compose.yml

			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
			echo "Первоначальное имя пользователя: admin"
			echo "Начальный пароль: умами"
		}

		docker_app_update() {
			cd  /home/docker/umami/ && docker compose down --rmi all
			cd  /home/docker/umami/
			git pull ${gh_proxy}github.com/umami-software/umami.git main > /dev/null 2>&1
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/umami/docker-compose.yml
			cd  /home/docker/umami/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/umami/ && docker compose down --rmi all
			rm -rf /home/docker/umami
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;

	  104|nginx-stream)
		stream_panel
		  ;;


	  105|siyuan)

		local app_id="105"
		local docker_name="siyuan"
		local docker_img="b3log/siyuan"
		local docker_port=8105

		docker_rum() {

			read -e -p "Установить пароль для входа:" app_passwd

			docker run -d \
			  --name siyuan \
			  --restart=always \
			  -v /home/docker/siyuan/workspace:/siyuan/workspace \
			  -p ${docker_port}:6806 \
			  -e PUID=1001 \
			  -e PGID=1002 \
			  b3log/siyuan \
			  --workspace=/siyuan/workspace/ \
			  --accessAuthCode="${app_passwd}"

		}

		local docker_describe="Siyuan Notes — это система управления знаниями, ориентированная на конфиденциальность."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/siyuan-note/siyuan"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  106|drawnix)

		local app_id="106"
		local docker_name="drawnix"
		local docker_img="pubuzhixing/drawnix"
		local docker_port=8106

		docker_rum() {

			docker run -d \
			   --restart=always  \
			   --name drawnix \
			   -p ${docker_port}:80 \
			  pubuzhixing/drawnix

		}

		local docker_describe="Это мощный инструмент для доски с открытым исходным кодом, который объединяет интеллектуальные карты, блок-схемы и т. д."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/plait-board/drawnix"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  107|pansou)

		local app_id="107"
		local docker_name="pansou"
		local docker_img="ghcr.io/fish2018/pansou-web"
		local docker_port=8107

		docker_rum() {

			docker run -d \
			  --name pansou \
			  --restart=always \
			  -p ${docker_port}:80 \
			  -v /home/docker/pansou/data:/app/data \
			  -v /home/docker/pansou/logs:/app/logs \
			  -e ENABLED_PLUGINS="hunhepan,jikepan,panwiki,pansearch,panta,qupansou,
susu,thepiratebay,wanou,xuexizhinan,panyq,zhizhen,labi,muou,ouge,shandian,
duoduo,huban,cyg,erxiao,miaoso,fox4k,pianku,clmao,wuji,cldi,xiaozhang,
libvio,leijing,xb6v,xys,ddys,hdmoli,yuhuage,u3c3,javdb,clxiong,jutoushe,
sdso,xiaoji,xdyh,haisou,bixin,djgou,nyaa,xinjuc,aikanzy,qupanshe,xdpan,
discourse,yunsou,ahhhhfs,nsgame,gying" \
			  ghcr.io/fish2018/pansou-web

		}

		local docker_describe="PanSou — это высокопроизводительный API-сервис поиска ресурсов сетевых дисков."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/fish2018/pansou"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;




	  108|langbot)
		local app_id="108"
		local app_name="Чат-бот LangBot"
		local app_text="Это платформа разработки роботов для обмена мгновенными сообщениями с открытым исходным кодом, основанная на большой языковой модели."
		local app_url="Официальный сайт:${gh_https_url}github.com/langbot-app/LangBot"
		local docker_name="langbot_plugin_runtime"
		local docker_port="8108"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/langbot-app/LangBot && cd LangBot/docker
			sed -i "s/5300:5300/${docker_port}:5300/g" /home/docker/LangBot/docker/docker-compose.yaml

			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/LangBot/docker && docker compose down --rmi all
			cd  /home/docker/LangBot/
			git pull ${gh_proxy}github.com/langbot-app/LangBot main > /dev/null 2>&1
			sed -i "s/5300:5300/${docker_port}:5300/g" /home/docker/LangBot/docker/docker-compose.yaml
			cd  /home/docker/LangBot/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/LangBot/docker/ && docker compose down --rmi all
			rm -rf /home/docker/LangBot
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;


	  109|zfile)

		local app_id="109"
		local docker_name="zfile"
		local docker_img="zhaojun1998/zfile:latest"
		local docker_port=8109

		docker_rum() {


			docker run -d --name=zfile --restart=always \
				-p ${docker_port}:8080 \
				-v /home/docker/zfile/db:/root/.zfile-v4/db \
				-v /home/docker/zfile/logs:/root/.zfile-v4/logs \
				-v /home/docker/zfile/file:/data/file \
				-v /home/docker/zfile/application.properties:/root/.zfile-v4/application.properties \
				zhaojun1998/zfile:latest


		}

		local docker_describe="Это онлайн-сетевая дисковая программа, подходящая для отдельных лиц или небольших групп."
		local docker_url="Официальный сайт: введение:${gh_https_url}github.com/zfile-dev/zfile"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  110|karakeep)
		local app_id="110"
		local app_name="управление закладками каракипа"
		local app_text="— это автономное приложение для создания закладок с возможностями искусственного интеллекта, предназначенное для накопителей данных."
		local app_url="Официальный сайт:${gh_https_url}github.com/karakeep-app/karakeep"
		local docker_name="docker-web-1"
		local docker_port="8110"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/karakeep-app/karakeep.git && cd karakeep/docker && cp .env.sample .env
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/karakeep/docker/docker-compose.yml

			docker compose up -d
			clear
			echo "Установка завершена"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/karakeep/docker/ && docker compose down --rmi all
			cd  /home/docker/karakeep/
			git pull ${gh_proxy}github.com/karakeep-app/karakeep.git main > /dev/null 2>&1
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/karakeep/docker/docker-compose.yml
			cd  /home/docker/karakeep/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/karakeep/docker/ && docker compose down --rmi all
			rm -rf /home/docker/karakeep
			echo "Приложение удалено"
		}

		docker_app_plus

		  ;;



	  111|convertx)

		local app_id="111"
		local docker_name="convertx"
		local docker_img="ghcr.io/c4illin/convertx:latest"
		local docker_port=8111

		docker_rum() {

			docker run -d --name=${docker_name} --restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/convertx:/app/data \
				${docker_img}

		}

		local docker_describe="Это мощный многоформатный инструмент для преобразования файлов (поддерживает документы, изображения, аудио и видео и т. д.). Настоятельно рекомендуется добавить доступ к доменному имени."
		local docker_url="Адрес проекта:${gh_https_url}github.com/c4illin/ConvertX"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app

		  ;;


	  112|lucky)

		local app_id="112"
		local docker_name="lucky"
		local docker_img="gdy666/lucky:v2"
		# Поскольку Lucky использует режим хост-сети, порт здесь предназначен только для справки/пояснения и фактически контролируется самим приложением (по умолчанию 16601).
		local docker_port=8112

		docker_rum() {

			docker run -d --name=${docker_name} --restart=always \
				--network host \
				-v /home/docker/lucky/conf:/app/conf \
				-v /var/run/docker.sock:/var/run/docker.sock \
				${docker_img}

			echo "Ждем, пока Lucky инициализируется..."
			sleep 10
			docker exec lucky /app/lucky -rSetHttpAdminPort ${docker_port}

		}

		local docker_describe="Lucky — это крупный инструмент управления проникновением в интрасеть и переадресацией портов, который поддерживает DDNS, обратный прокси-сервер, WOL и другие функции."
		local docker_url="Адрес проекта:${gh_https_url}github.com/gdy666/lucky"
		local docker_use="echo \"Пароль учетной записи по умолчанию: 666\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  113|firefox)

		local app_id="113"
		local docker_name="firefox"
		local docker_img="jlesage/firefox:latest"
		local docker_port=8113

		docker_rum() {

			read -e -p "Установить пароль для входа:" admin_password

			docker run -d --name=${docker_name} --restart=always \
				-p ${docker_port}:5800 \
				-v /home/docker/firefox:/config:rw \
				-e ENABLE_CJK_FONT=1 \
				-e WEB_AUDIO=1 \
				-e VNC_PASSWORD="${admin_password}" \
				${docker_img}
		}

		local docker_describe="Это браузер Firefox, работающий в Docker, который поддерживает прямой доступ к интерфейсу браузера рабочего стола через веб-страницу."
		local docker_url="Адрес проекта:${gh_https_url}github.com/jlesage/docker-firefox"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  114|Moltbot|ClawdBot|moltbot|clawdbot|openclaw|OpenClaw)
	  	  moltbot_menu
		  ;;


	  b)
	  	clear
	  	send_stats "Резервное копирование всех приложений"

	  	local backup_filename="app_$(date +"%Y%m%d%H%M%S").tar.gz"
	  	echo -e "${gl_kjlan}Резервное копирование$backup_filename ...${gl_bai}"
	  	cd / && tar czvf "$backup_filename" home

	  	while true; do
			clear
			echo "Создан файл резервной копии: /$backup_filename"
			read -e -p "Хотите перенести резервные данные на удаленный сервер? (Да/Нет):" choice
			case "$choice" in
			  [Yy])
				read -e -p "Пожалуйста, введите IP-адрес удаленного сервера:" remote_ip
				read -e -p "SSH-порт целевого сервера [по умолчанию 22]:" TARGET_PORT
				local TARGET_PORT=${TARGET_PORT:-22}

				if [ -z "$remote_ip" ]; then
				  echo "Ошибка: введите IP-адрес удаленного сервера."
				  continue
				fi
				local latest_tar=$(ls -t /app*.tar.gz | head -1)
				if [ -n "$latest_tar" ]; then
				  ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
				  sleep 2  # 添加等待时间
				  scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/"
				  echo "Файл перенесен в удаленный сервер/корневой каталог."
				else
				  echo "Файл для передачи не найден."
				fi
				break
				;;
			  *)
				echo "Примечание. Текущая резервная копия включает только проекты Docker и не включает резервные копии данных панелей создания веб-сайтов, таких как Pagoda и 1panel."
				break
				;;
			esac
	  	done

		  ;;

	  r)
	  	root_use
	  	send_stats "Восстановить все приложения"
	  	echo "Доступные резервные копии приложений"
	  	echo "-------------------------"
	  	ls -lt /app*.gz | awk '{print $NF}'
	  	echo ""
	  	read -e -p  "Нажмите клавишу Enter, чтобы восстановить последнюю резервную копию, введите имя файла резервной копии, чтобы восстановить указанную резервную копию, введите 0, чтобы выйти:" filename

	  	if [ "$filename" == "0" ]; then
			  break_end
			  linux_panel
	  	fi

	  	# Если пользователь не вводит имя файла, используется последний сжатый пакет.
	  	if [ -z "$filename" ]; then
			  local filename=$(ls -t /app*.tar.gz | head -1)
	  	fi

	  	if [ -n "$filename" ]; then
		  	  echo -e "${gl_kjlan}Распаковка$filename ...${gl_bai}"
		  	  cd / && tar -xzf "$filename"
			  echo "Данные приложения восстановлены. В настоящее время вручную войдите в указанное меню приложения и обновите приложение, чтобы восстановить его."
	  	else
			  echo "Сжатый пакет не найден."
	  	fi

		  ;;

	  0)
		  kejilion
		  ;;
	  *)
		cd ~
		install git
		if [ ! -d apps/.git ]; then
			timeout 10s git clone ${gh_proxy}github.com/kejilion/apps.git
		else
			cd apps
			# git pull origin main > /dev/null 2>&1
			timeout 10s git pull ${gh_proxy}github.com/kejilion/apps.git main > /dev/null 2>&1
		fi
		local custom_app="$HOME/apps/${sub_choice}.conf"
		if [ -f "$custom_app" ]; then
			. "$custom_app"
		else
			echo -e "${gl_hong}Ошибка: Не найден по номеру${sub_choice}конфигурация приложения${gl_bai}"
		fi
		  ;;
	esac
	break_end
	sub_choice=""

done
}



linux_work() {

	while true; do
	  clear
	  send_stats "Серверная рабочая область"
	  echo -e "Серверная рабочая область"
	  echo -e "Система предоставит вам рабочее пространство, которое может постоянно работать в фоновом режиме и которое вы можете использовать для выполнения долгосрочных задач."
	  echo -e "Даже если вы отключите SSH, выполнение задач в рабочей области не будет прерываться, а задачи останутся в фоновом режиме."
	  echo -e "${gl_huang}намекать:${gl_bai}После входа в рабочую область используйте Ctrl+b, а затем нажмите только d, чтобы выйти из рабочей области!"
	  echo -e "${gl_kjlan}------------------------"
	  echo "Список существующих на данный момент рабочих пространств"
	  echo -e "${gl_kjlan}------------------------"
	  tmux list-sessions
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}Рабочая зона 1"
	  echo -e "${gl_kjlan}2.   ${gl_bai}Рабочая зона 2"
	  echo -e "${gl_kjlan}3.   ${gl_bai}Рабочая зона 3"
	  echo -e "${gl_kjlan}4.   ${gl_bai}Рабочая зона 4"
	  echo -e "${gl_kjlan}5.   ${gl_bai}Рабочее пространство №5"
	  echo -e "${gl_kjlan}6.   ${gl_bai}Рабочая зона 6"
	  echo -e "${gl_kjlan}7.   ${gl_bai}Рабочая зона 7"
	  echo -e "${gl_kjlan}8.   ${gl_bai}Рабочая зона 8"
	  echo -e "${gl_kjlan}9.   ${gl_bai}Рабочее пространство №9"
	  echo -e "${gl_kjlan}10.  ${gl_bai}Рабочее пространство 10"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}Резидентный режим SSH${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}22.  ${gl_bai}Создать/ввести рабочее пространство"
	  echo -e "${gl_kjlan}23.  ${gl_bai}Внедрение команд в фоновую рабочую область"
	  echo -e "${gl_kjlan}24.  ${gl_bai}Удалить указанное рабочее пространство"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in

		  1)
			  clear
			  install tmux
			  local SESSION_NAME="work1"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run

			  ;;
		  2)
			  clear
			  install tmux
			  local SESSION_NAME="work2"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  3)
			  clear
			  install tmux
			  local SESSION_NAME="work3"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  4)
			  clear
			  install tmux
			  local SESSION_NAME="work4"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  5)
			  clear
			  install tmux
			  local SESSION_NAME="work5"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  6)
			  clear
			  install tmux
			  local SESSION_NAME="work6"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  7)
			  clear
			  install tmux
			  local SESSION_NAME="work7"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  8)
			  clear
			  install tmux
			  local SESSION_NAME="work8"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  9)
			  clear
			  install tmux
			  local SESSION_NAME="work9"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;
		  10)
			  clear
			  install tmux
			  local SESSION_NAME="work10"
			  send_stats "Начать рабочую область$SESSION_NAME"
			  tmux_run
			  ;;

		  21)
			while true; do
			  clear
			  if grep -q 'tmux attach-session -t sshd || tmux new-session -s sshd' ~/.bashrc; then
				  local tmux_sshd_status="${gl_lv}включать${gl_bai}"
			  else
				  local tmux_sshd_status="${gl_hui}закрытие${gl_bai}"
			  fi
			  send_stats "Резидентный режим SSH"
			  echo -e "Резидентный режим SSH${tmux_sshd_status}"
			  echo "После открытия SSH-соединения он сразу перейдет в резидентный режим и вернется в предыдущее рабочее состояние."
			  echo "------------------------"
			  echo "1. Вкл. 2. Выкл."
			  echo "------------------------"
			  echo "0. Вернуться в предыдущее меню"
			  echo "------------------------"
			  read -e -p "Пожалуйста, введите ваш выбор:" gongzuoqu_del
			  case "$gongzuoqu_del" in
				1)
			  	  install tmux
			  	  local SESSION_NAME="sshd"
			  	  send_stats "Начать рабочую область$SESSION_NAME"
				  grep -q "tmux attach-session -t sshd" ~/.bashrc || echo -e "\n# Автоматический вход в сеанс tmux\nif [[ -z \"\$TMUX\" ]]; then\n    tmux attach-session -t sshd || tmux new-session -s sshd\nfi" >> ~/.bashrc
				  source ~/.bashrc
			  	  tmux_run
				  ;;
				2)
				  sed -i '/# Автоматически войти в сеанс tmux/,+4d' ~/.bashrc
				  tmux kill-window -t sshd
				  ;;
				*)
				  break
				  ;;
			  esac
			done
			  ;;

		  22)
			  read -e -p "Введите имя рабочей области, которую вы создали или ввели, например 1001 kj001 work1:" SESSION_NAME
			  tmux_run
			  send_stats "Пользовательское рабочее пространство"
			  ;;


		  23)
			  read -e -p "Введите команду, которую вы хотите выполнить в фоновом режиме, например: Curl -fsSL https://get.docker.com | ш:" tmuxd
			  tmux_run_d
			  send_stats "Внедрение команд в фоновую рабочую область"
			  ;;

		  24)
			  read -e -p "Пожалуйста, введите имя рабочей области, которую вы хотите удалить:" gongzuoqu_name
			  tmux kill-window -t $gongzuoqu_name
			  send_stats "Удалить рабочую область"
			  ;;

		  0)
			  kejilion
			  ;;
		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end

	done


}










# Интеллектуальная функция переключения зеркального источника
switch_mirror() {
	# Необязательный параметр, по умолчанию — false
	local upgrade_software=${1:-false}
	local clean_cache=${2:-false}

	# Получить страну пользователя
	local country
	country=$(curl -s ipinfo.io/country)

	echo "Обнаружены страны:$country"

	if [ "$country" = "CN" ]; then
		echo "Используйте отечественные зеркальные источники..."
		bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
		  --source mirrors.huaweicloud.com \
		  --protocol https \
		  --use-intranet-source false \
		  --backup true \
		  --upgrade-software "$upgrade_software" \
		  --clean-cache "$clean_cache" \
		  --ignore-backup-tips \
		  --install-epel false \
		  --pure-mode
	else
		echo "Используйте зарубежные зеркальные источники..."
		if [ -f /etc/os-release ] && grep -qi "oracle" /etc/os-release; then
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
			  --source mirrors.xtom.com \
			  --protocol https \
			  --use-intranet-source false \
			  --backup true \
			  --upgrade-software "$upgrade_software" \
			  --clean-cache "$clean_cache" \
			  --ignore-backup-tips \
			  --install-epel false \
			  --pure-mode
		else
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
				--use-official-source true \
				--protocol https \
				--use-intranet-source false \
				--backup true \
				--upgrade-software "$upgrade_software" \
				--clean-cache "$clean_cache" \
				--ignore-backup-tips \
				--install-epel false \
				--pure-mode
		fi
	fi
}


fail2ban_panel() {
		  root_use
		  send_stats "SSH-защита"
		  while true; do

				check_f2b_status
				echo -e "Программа защиты SSH$check_f2b_status"
				echo "Fail2ban — это инструмент SSH для предотвращения взлома методом грубой силы."
				echo "Официальный сайт: введение:${gh_proxy}github.com/fail2ban/fail2ban"
				echo "------------------------"
				echo "1. Установите защитную программу"
				echo "------------------------"
				echo "2. Просмотр записей перехвата SSH"
				echo "3. Мониторинг журналов в реальном времени."
				echo "------------------------"
				echo "9. Удалите программу защиты."
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
				case $sub_choice in
					1)
						f2b_install_sshd
						cd ~
						f2b_status
						break_end
						;;
					2)
						echo "------------------------"
						f2b_sshd
						echo "------------------------"
						break_end
						;;
					3)
						tail -f /var/log/fail2ban.log
						break
						;;
					9)
						remove fail2ban
						rm -rf /etc/fail2ban
						echo "Защитная программа Fail2Ban удалена."
						break
						;;
					*)
						break
						;;
				esac
		  done

}





net_menu() {

	send_stats "Инструмент управления сетевой картой"
	show_nics() {
		echo "================ Текущая информация о сетевой карте ================"
		printf "%-18s %-12s %-20s %-26s\n" "Имя сетевой карты" "состояние" "IP-адрес" "MAC-адрес"
		echo "------------------------------------------------"
		for nic in $(ls /sys/class/net); do
			state=$(cat /sys/class/net/$nic/operstate 2>/dev/null)
			ipaddr=$(ip -4 addr show $nic | awk '/inet /{print $2}' | head -n1)
			mac=$(cat /sys/class/net/$nic/address 2>/dev/null)
			printf "%-15s %-10s %-18s %-20s\n" "$nic" "$state" "${ipaddr:-无}" "$mac"
		done
		echo "================================================"
	}

	while true; do
		clear
		show_nics
		echo
		echo "=========== Меню управления сетевой картой ==========="
		echo "1. Включите сетевую карту."
		echo "2. Отключите сетевую карту."
		echo "3. Просмотр сведений о сетевой карте"
		echo "4. Обновите информацию о сетевой карте."
		echo "0. Вернуться в предыдущее меню"
		echo "===================================="
		read -erp "Пожалуйста, выберите действие:" choice

		case $choice in
			1)
				send_stats "Включить сетевую карту"
				read -erp "Пожалуйста, введите имя сетевой карты, которую необходимо включить:" nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" up && echo "✔ Сетевая карта$nicВключено"
				else
					echo "✘ Сетевая карта не существует"
				fi
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			2)
				send_stats "Отключить сетевую карту"
				read -erp "Пожалуйста, введите имя сетевой карты, которую необходимо отключить:" nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" down && echo "✔ Сетевая карта$nicНеполноценный"
				else
					echo "✘ Сетевая карта не существует"
				fi
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			3)
				send_stats "Просмотр сведений о сетевой карте"
				read -erp "Пожалуйста, введите имя сетевой карты, которую вы хотите просмотреть:" nic
				if ip link show "$nic" &>/dev/null; then
					echo "========== $nicПодробности =========="
					ip addr show "$nic"
					ethtool "$nic" 2>/dev/null | head -n 10
				else
					echo "✘ Сетевая карта не существует"
				fi
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			4)
				send_stats "Обновить информацию о сетевой карте."
				continue
				;;
			*)
				break
				;;
		esac
	done
}



log_menu() {
	send_stats "Инструмент управления системным журналом"

	show_log_overview() {
		echo "============= Обзор системного журнала ============="
		echo "Имя хоста: $(имя хоста)"
		echo "Системное время: $(дата)"
		echo
		echo "[занятие каталога /var/log]"
		du -sh /var/log 2>/dev/null
		echo
		echo "[занятие в журнале]"
		journalctl --disk-usage 2>/dev/null
		echo "========================================"
	}

	while true; do
		clear
		show_log_overview
		echo
		echo "=========== Меню управления системным журналом ==========="
		echo "1. Проверьте последний системный журнал (журнал)"
		echo "2. Просмотр указанного журнала службы."
		echo "3. Просмотр журналов входа и безопасности."
		echo "4. Журналы отслеживания в реальном времени."
		echo "5. Очистите старые журналы журналов."
		echo "0. Вернуться в предыдущее меню"
		echo "======================================="
		read -erp "Пожалуйста, выберите действие:" choice

		case $choice in
			1)
				send_stats "Просмотр последних журналов"
				read -erp "Сколько последних строк журнала вы просмотрели? [По умолчанию 100]:" lines
				lines=${lines:-100}
				journalctl -n "$lines" --no-pager
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			2)
				send_stats "Просмотр указанных журналов служб"
				read -erp "Введите имя службы (например, sshd, nginx):" svc
				if systemctl list-unit-files | grep -q "^$svc"; then
					journalctl -u "$svc" -n 100 --no-pager
				else
					echo "✘ Сервис не существует или не имеет логов"
				fi
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			3)
				send_stats "Просмотр журналов входа и безопасности"
				echo "====== Журнал последних входов ======"
				last -n 10
				echo
				echo "====== Журнал аутентификации ======"
				if [ -f /var/log/secure ]; then
					tail -n 20 /var/log/secure
				elif [ -f /var/log/auth.log ]; then
					tail -n 20 /var/log/auth.log
				else
					echo "Файл журнала безопасности не найден"
				fi
				read -erp "Нажмите Enter, чтобы продолжить..."
				;;
			4)
				send_stats "Журнал отслеживания в реальном времени"
				echo "1) Системный журнал"
				echo "2) Указать журнал обслуживания"
				read -erp "Выберите тип отслеживания:" t
				if [ "$t" = "1" ]; then
					journalctl -f
				elif [ "$t" = "2" ]; then
					read -erp "Введите название услуги:" svc
					journalctl -u "$svc" -f
				else
					echo "Неверный выбор"
				fi
				;;
			5)
				send_stats "Очистите старые журналы журналов"
				echo "⚠️ Очистите журнал (безопасный способ)"
				echo "1) Сохранить последние 7 дней"
				echo "2) Сохранить последние 3 дня"
				echo "3) Ограничьте максимальный размер журнала до 500 МБ."
				read -erp "Пожалуйста, выберите метод очистки:" c
				case $c in
					1) journalctl --vacuum-time=7d ;;
					2) journalctl --vacuum-time=3d ;;
					3) journalctl --vacuum-size=500M ;;
					*) echo "Неверный вариант" ;;
				esac
				echo "✔ Очистка журнала журнала завершена"
				sleep 2
				;;
			*)
				break
				;;
		esac
	done
}



env_menu() {

	BASHRC="$HOME/.bashrc"
	PROFILE="$HOME/.profile"

	send_stats "Инструмент управления системными переменными"

	show_env_vars() {
		clear
		send_stats "Действующие в настоящее время переменные среды"
		echo "========== Действующие в настоящее время переменные среды (выдержка) =========="
		printf "%-20s %s\n" "имя переменной" "ценить"
		echo "-----------------------------------------------"
		for v in USER HOME SHELL LANG PWD; do
			printf "%-20s %s\n" "$v" "${!v}"
		done

		echo
		echo "PATH:"
		echo "$PATH" | tr ':' '\n' | nl -ba

		echo
		echo "========== Переменные, определенные в файле конфигурации (парсинг) =========="

		parse_file_vars() {
			local file="$1"
			[ -f "$file" ] || return

			echo
			echo ">>> Исходный файл:$file"
			echo "-----------------------------------------------"

			# Экспорт экстракта VAR=xxx или VAR=xxx
			grep -Ev '^\s*#|^\s*$' "$file" \
			| grep -E '^(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=' \
			| while read -r line; do
				var=$(echo "$line" | sed -E 's/^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*).*/\2/')
				val=$(echo "$line" | sed -E 's/^[^=]+=//')
				printf "%-20s %s\n" "$var" "$val"
			done
		}

		parse_file_vars "$HOME/.bashrc"
		parse_file_vars "$HOME/.profile"

		echo
		echo "==============================================="
		read -erp "Нажмите Enter, чтобы продолжить..."
	}


	view_file() {
		local file="$1"
		send_stats "Просмотр файла переменных$file"
		clear
		if [ -f "$file" ]; then
			echo "========== Просмотр файлов:$file =========="
			cat -n "$file"
			echo "===================================="
		else
			echo "Файл не существует:$file"
		fi
		read -erp "Нажмите Enter, чтобы продолжить..."
	}

	edit_file() {
		local file="$1"
		send_stats "Редактировать файл переменных$file"
		install nano
		nano "$file"
	}

	source_files() {
		echo "Перезагрузка переменных среды..."
		send_stats "Перезагрузка переменных среды"
		source "$BASHRC"
		source "$PROFILE"
		echo "✔ Переменные среды были перезагружены."
		read -erp "Нажмите Enter, чтобы продолжить..."
	}

	while true; do
		clear
		echo "=========== Управление переменными системной среды =========="
		echo "Текущий пользователь:$USER"
		echo "--------------------------------------"
		echo "1. Проверьте текущие часто используемые переменные среды."
		echo "2. Просмотр ~/.bashrc"
		echo "3. Просмотр ~/.profile"
		echo "4. Отредактируйте ~/.bashrc."
		echo "5. Отредактируйте ~/.profile"
		echo "6. Перезагрузите переменные среды (источник)"
		echo "--------------------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "--------------------------------------"
		read -erp "Пожалуйста, выберите действие:" choice

		case "$choice" in
			1)
				show_env_vars
				;;
			2)
				view_file "$BASHRC"
				;;
			3)
				view_file "$PROFILE"
				;;
			4)
				edit_file "$BASHRC"
				;;
			5)
				edit_file "$PROFILE"
				;;
			6)
				source_files
				;;
			0)
				break
				;;
			*)
				echo "Неверный вариант"
				sleep 1
				;;
		esac
	done
}


create_user_with_sshkey() {
	local new_username="$1"
	local is_sudo="${2:-false}"
	local sshkey_vl

	if [[ -z "$new_username" ]]; then
		echo "Использование: create_user_with_sshkey <имя пользователя>"
		return 1
	fi

	# Создать пользователя
	useradd -m -s /bin/bash "$new_username" || return 1

	echo "Пример импорта открытого ключа:"
	echo "  - URL：      ${gh_https_url}github.com/torvalds.keys"
	echo "- Вставьте напрямую: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
	read -e -p "Пожалуйста, импортируйте${new_username}открытый ключ:" sshkey_vl

	case "$sshkey_vl" in
		http://*|https://*)
			send_stats "Импортировать открытый ключ SSH из URL"
			fetch_remote_ssh_keys "$sshkey_vl" "/home/$new_username"
			;;
		ssh-rsa*|ssh-ed25519*|ssh-ecdsa*)
			send_stats "Непосредственно импортируйте открытый ключ"
			import_sshkey "$sshkey_vl" "/home/$new_username"
			;;
		*)
			echo "Ошибка: неизвестный параметр '$sshkey_vl'"
			return 1
			;;
	esac


	# Исправить разрешения
	chown -R "$new_username:$new_username" "/home/$new_username/.ssh"

	install sudo

	# sudo без пароля
	if [[ "$is_sudo" == "true" ]]; then
		cat >"/etc/sudoers.d/$new_username" <<EOF
$new_username ALL=(ALL) NOPASSWD:ALL
EOF
		chmod 440 "/etc/sudoers.d/$new_username"
	fi

	sed -i '/^\s*#\?\s*UsePAM\s\+/d' /etc/ssh/sshd_config
	echo 'UsePAM yes' >> /etc/ssh/sshd_config
	passwd -l "$new_username" &>/dev/null
	restart_ssh

	echo "пользователь$new_usernameСоздание завершено"
}















linux_Settings() {

	while true; do
	  clear
	  # send_stats «Системные инструменты»
	  echo -e "системные инструменты"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}Установить горячую клавишу запуска сценария${gl_kjlan}2.   ${gl_bai}Изменить пароль для входа"
	  echo -e "${gl_kjlan}3.   ${gl_bai}Режим входа в систему с паролем пользователя${gl_kjlan}4.   ${gl_bai}Установите указанную версию Python"
	  echo -e "${gl_kjlan}5.   ${gl_bai}Открыть все порты${gl_kjlan}6.   ${gl_bai}Изменить порт подключения SSH"
	  echo -e "${gl_kjlan}7.   ${gl_bai}Оптимизировать DNS-адрес${gl_kjlan}8.   ${gl_bai}Переустановите систему в один клик${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}9.   ${gl_bai}Отключите учетную запись ROOT и создайте новую учетную запись.${gl_kjlan}10.  ${gl_bai}Переключить приоритет ipv4/ipv6"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}Проверить статус занятости порта${gl_kjlan}12.  ${gl_bai}Изменить размер виртуальной памяти"
	  echo -e "${gl_kjlan}13.  ${gl_bai}Управление пользователями${gl_kjlan}14.  ${gl_bai}Генератор пользователя/пароля"
	  echo -e "${gl_kjlan}15.  ${gl_bai}Настройка часового пояса системы${gl_kjlan}16.  ${gl_bai}Настройте ускорение BBR3"
	  echo -e "${gl_kjlan}17.  ${gl_bai}Расширенный менеджер брандмауэра${gl_kjlan}18.  ${gl_bai}Изменить имя хоста"
	  echo -e "${gl_kjlan}19.  ${gl_bai}Переключить источник обновления системы${gl_kjlan}20.  ${gl_bai}Управление запланированными задачами"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}Собственное разрешение хоста${gl_kjlan}22.  ${gl_bai}Программа защиты SSH"
	  echo -e "${gl_kjlan}23.  ${gl_bai}Автоматическое отключение с ограничением тока${gl_kjlan}24.  ${gl_bai}Режим входа в систему с помощью ключа пользователя"
	  echo -e "${gl_kjlan}25.  ${gl_bai}Мониторинг системы и раннее предупреждение TG-bot${gl_kjlan}26.  ${gl_bai}Исправьте уязвимости OpenSSH высокого риска."
	  echo -e "${gl_kjlan}27.  ${gl_bai}Обновление ядра Red Hat Linux${gl_kjlan}28.  ${gl_bai}Оптимизация параметров ядра системы Linux${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}29.  ${gl_bai}Инструменты сканирования вирусов${gl_huang}★${gl_bai}                     ${gl_kjlan}30.  ${gl_bai}файловый менеджер"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}31.  ${gl_bai}Переключить язык системы${gl_kjlan}32.  ${gl_bai}Инструмент украшения командной строки${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}Настроить системную корзину${gl_kjlan}34.  ${gl_bai}Резервное копирование и восстановление системы"
	  echo -e "${gl_kjlan}35.  ${gl_bai}инструмент удаленного подключения ssh${gl_kjlan}36.  ${gl_bai}Инструмент управления разделами жесткого диска"
	  echo -e "${gl_kjlan}37.  ${gl_bai}История командной строки${gl_kjlan}38.  ${gl_bai}инструмент удаленной синхронизации rsync"
	  echo -e "${gl_kjlan}39.  ${gl_bai}Избранное команд${gl_huang}★${gl_bai}                       ${gl_kjlan}40.  ${gl_bai}Инструмент управления сетевой картой"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}41.  ${gl_bai}Инструмент управления системным журналом${gl_huang}★${gl_bai}                 ${gl_kjlan}42.  ${gl_bai}Инструмент управления системными переменными"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}61.  ${gl_bai}доска объявлений${gl_kjlan}66.  ${gl_bai}Универсальная настройка системы${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}99.  ${gl_bai}Перезагрузите сервер${gl_kjlan}100. ${gl_bai}Конфиденциальность и безопасность"
	  echo -e "${gl_kjlan}101. ${gl_bai}Расширенное использование команды k${gl_huang}★${gl_bai}                    ${gl_kjlan}102. ${gl_bai}Удалить скрипт технологического льва"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			  while true; do
				  clear
				  read -e -p "Пожалуйста, введите сочетания клавиш (введите 0 для выхода):" kuaijiejian
				  if [ "$kuaijiejian" == "0" ]; then
					   break_end
					   linux_Settings
				  fi
				  find /usr/local/bin/ -type l -exec bash -c 'test "$(readlink -f {})" = "/usr/local/bin/k" && rm -f {}' \;
				  if [ "$kuaijiejian" != "k" ]; then
					  ln -sf /usr/local/bin/k /usr/local/bin/$kuaijiejian
				  fi
				  ln -sf /usr/local/bin/k /usr/bin/$kuaijiejian > /dev/null 2>&1
				  echo "Сочетания клавиш установлены."
				  send_stats "Быстрая клавиша сценария установлена."
				  break_end
				  linux_Settings
			  done
			  ;;

		  2)
			  clear
			  send_stats "Установите пароль для входа"
			  echo "Установите пароль для входа"
			  passwd
			  ;;
		  3)
			  clear
			  add_sshpasswd
			  ;;

		  4)
			root_use
			send_stats "управление версиями py"
			echo "управление версиями Python"
			echo "Видео-знакомство: https://www.bilibili.com/video/BV1Pm42157cK?t=0.1"
			echo "---------------------------------------"
			echo "Эта функция позволяет легко установить любую версию, официально поддерживаемую Python!"
			local VERSION=$(python3 -V 2>&1 | awk '{print $2}')
			echo -e "Текущий номер версии Python:${gl_huang}$VERSION${gl_bai}"
			echo "------------"
			echo "Рекомендуемые версии: 3.12 3.11 3.10 3.9 3.8 2.7"
			echo "Проверьте другие версии: https://www.python.org/downloads/."
			echo "------------"
			read -e -p "Введите номер версии Python, которую вы хотите установить (введите 0 для выхода):" py_new_v


			if [[ "$py_new_v" == "0" ]]; then
				send_stats "Скрипт управления PY"
				break_end
				linux_Settings
			fi


			if ! grep -q 'export PYENV_ROOT="\$HOME/.pyenv"' ~/.bashrc; then
				if command -v yum &>/dev/null; then
					yum update -y && yum install git -y
					yum groupinstall "Development Tools" -y
					yum install openssl-devel bzip2-devel libffi-devel ncurses-devel zlib-devel readline-devel sqlite-devel xz-devel findutils -y

					curl -O https://www.openssl.org/source/openssl-1.1.1u.tar.gz
					tar -xzf openssl-1.1.1u.tar.gz
					cd openssl-1.1.1u
					./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
					make
					make install
					echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1u.conf
					ldconfig -v
					cd ..

					export LDFLAGS="-L/usr/local/openssl/lib"
					export CPPFLAGS="-I/usr/local/openssl/include"
					export PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig"

				elif command -v apt &>/dev/null; then
					apt update -y && apt install git -y
					apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libnss3-dev libedit-dev -y
				elif command -v apk &>/dev/null; then
					apk update && apk add git
					apk add --no-cache bash gcc musl-dev libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev libc6-compat linux-headers make xz-dev build-base  ncurses-dev
				else
					echo "Неизвестный менеджер пакетов!"
					return
				fi

				curl https://pyenv.run | bash
				cat << EOF >> ~/.bashrc

export PYENV_ROOT="\$HOME/.pyenv"
if [[ -d "\$PYENV_ROOT/bin" ]]; then
  export PATH="\$PYENV_ROOT/bin:\$PATH"
fi
eval "\$(pyenv init --path)"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOF

			fi

			sleep 1
			source ~/.bashrc
			sleep 1
			pyenv install $py_new_v
			pyenv global $py_new_v

			rm -rf /tmp/python-build.*
			rm -rf $(pyenv root)/cache/*

			local VERSION=$(python -V 2>&1 | awk '{print $2}')
			echo -e "Текущий номер версии Python:${gl_huang}$VERSION${gl_bai}"
			send_stats "Скрипт переключения версии PY"

			  ;;

		  5)
			  root_use
			  send_stats "открытый порт"
			  iptables_open
			  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
			  echo "Все порты открыты"

			  ;;
		  6)
			root_use
			send_stats "Изменить SSH-порт"

			while true; do
				clear
				sed -i 's/^\s*#\?\s*Port/Port/' /etc/ssh/sshd_config

				# Прочитайте текущий номер порта SSH
				local current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

				# Распечатать текущий номер порта SSH
				echo -e "Текущий номер порта SSH:${gl_huang}$current_port ${gl_bai}"

				echo "------------------------"
				echo "Номер порта находится в диапазоне от 1 до 65535. (Введите 0 для выхода)"

				# Запросить у пользователя новый номер порта SSH
				read -e -p "Пожалуйста, введите новый номер порта SSH:" new_port

				# Определите, находится ли номер порта в допустимом диапазоне.
				if [[ $new_port =~ ^[0-9]+$ ]]; then  # 检查输入是否为数字
					if [[ $new_port -ge 1 && $new_port -le 65535 ]]; then
						send_stats "SSH-порт был изменен"
						new_ssh_port $new_port
					elif [[ $new_port -eq 0 ]]; then
						send_stats "Выйти из модификации порта SSH"
						break
					else
						echo "Номер порта недействителен. Пожалуйста, введите число от 1 до 65535."
						send_stats "Введен неверный порт SSH"
						break_end
					fi
				else
					echo "Неверный ввод, введите число."
					send_stats "Введен неверный порт SSH"
					break_end
				fi
			done


			  ;;


		  7)
			set_dns_ui
			  ;;

		  8)

			dd_xitong
			  ;;
		  9)
			root_use
			send_stats "Отключить root для новых пользователей"
			read -e -p "Пожалуйста, введите новое имя пользователя (введите 0 для выхода):" new_username
			if [ "$new_username" == "0" ]; then
				break_end
				linux_Settings
			fi

			create_user_with_sshkey $new_username true

			ssh-keygen -l -f /home/$new_username/.ssh/authorized_keys &>/dev/null && {
				passwd -l root &>/dev/null
				sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
			}

			;;


		  10)
			root_use
			send_stats "Установить приоритет v4/v6"
			while true; do
				clear
				echo "Установить приоритет v4/v6"
				echo "------------------------"


				if grep -Eq '^\s*precedence\s+::ffff:0:0/96\s+100\s*$' /etc/gai.conf 2>/dev/null; then
					echo -e "Текущие настройки приоритета сети:${gl_huang}IPv4${gl_bai}приоритет"
				else
					echo -e "Текущие настройки приоритета сети:${gl_huang}IPv6${gl_bai}приоритет"
				fi

				echo ""
				echo "------------------------"
				echo "1. Сначала IPv4 2. Сначала IPv6 3. Инструмент восстановления IPv6"
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Выберите предпочитаемую сеть:" choice

				case $choice in
					1)
						prefer_ipv4
						;;
					2)
						rm -f /etc/gai.conf
						echo "Сначала перешёл на IPv6"
						send_stats "Сначала перешёл на IPv6"
						;;

					3)
						clear
						bash <(curl -L -s jhb.ovh/jb/v6.sh)
						echo "Эту функцию предоставил jhb, спасибо ему!"
						send_stats "ремонт ipv6"
						;;

					*)
						break
						;;

				esac
			done
			;;

		  11)
			clear
			ss -tulnape
			;;

		  12)
			root_use
			send_stats "Настройка виртуальной памяти"
			while true; do
				clear
				echo "Настройка виртуальной памяти"
				local swap_used=$(free -m | awk 'NR==3{print $3}')
				local swap_total=$(free -m | awk 'NR==3{print $2}')
				local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

				echo -e "Текущая виртуальная память:${gl_huang}$swap_info${gl_bai}"
				echo "------------------------"
				echo "1. Выделить 1024M 2. Выделить 2048M 3. Выделить 4096M 4. Нестандартный размер"
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Пожалуйста, введите ваш выбор:" choice

				case "$choice" in
				  1)
					send_stats "Установлена ​​виртуальная память 1 ГБ."
					add_swap 1024

					;;
				  2)
					send_stats "Установлена ​​виртуальная память 2G."
					add_swap 2048

					;;
				  3)
					send_stats "Виртуальная память 4G настроена."
					add_swap 4096

					;;

				  4)
					read -e -p "Пожалуйста, введите размер виртуальной памяти (единица М):" new_swap
					add_swap "$new_swap"
					send_stats "Пользовательский набор виртуальной памяти"
					;;

				  *)
					break
					;;
				esac
			done
			;;

		  13)
			  while true; do
				root_use
				send_stats "Управление пользователями"
				echo "Список пользователей"
				echo "----------------------------------------------------------------------------"
				printf "%-24s %-34s %-20s %-10s\n" "имя пользователя" "Разрешения пользователя" "Группа пользователей" "разрешения sudo"
				while IFS=: read -r username _ userid groupid _ _ homedir shell; do
					local groups=$(groups "$username" | cut -d : -f 2)
					local sudo_status
					if sudo -n -lU "$username" 2>/dev/null | grep -q "(ALL) \(NOPASSWD: \)\?ALL"; then
						sudo_status="Yes"
					else
						sudo_status="No"
					fi
					printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
				done < /etc/passwd


				  echo ""
				  echo "Операции со счетом"
				  echo "------------------------"
				  echo "1. Создайте обычного пользователя 2. Создайте расширенного пользователя"
				  echo "------------------------"
				  echo "3. Предоставить высшие полномочия 4. Отменить высшие полномочия"
				  echo "------------------------"
				  echo "5. Удалить аккаунт"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
					   # Запросить у пользователя новое имя пользователя
					   read -e -p "Пожалуйста, введите новое имя пользователя:" new_username
					   create_user_with_sshkey $new_username false

						  ;;

					  2)
					   # Запросить у пользователя новое имя пользователя
					   read -e -p "Пожалуйста, введите новое имя пользователя:" new_username
					   create_user_with_sshkey $new_username true

						  ;;
					  3)
					   read -e -p "Пожалуйста, введите имя пользователя:" username
					   install sudo
					   cat >"/etc/sudoers.d/$username" <<EOF
$username ALL=(ALL) NOPASSWD:ALL
EOF
					  chmod 440 "/etc/sudoers.d/$username"

						  ;;
					  4)
					   read -e -p "Пожалуйста, введите имя пользователя:" username
				  	   if [[ -f "/etc/sudoers.d/$username" ]]; then
						   grep -lR "^$username" /etc/sudoers.d/ 2>/dev/null | xargs rm -f
					   fi
					   sed -i "/^$username\s*ALL=(ALL)/d" /etc/sudoers
						  ;;
					  5)
					   read -e -p "Пожалуйста, введите имя пользователя, которого хотите удалить:" username
					   userdel -r "$username"
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac

			  done
			  ;;

		  14)
			clear
			send_stats "Генератор пользовательской информации"
			echo "случайное имя пользователя"
			echo "------------------------"
			for i in {1..5}; do
				username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
				echo "случайное имя пользователя$i: $username"
			done

			echo ""
			echo "случайное имя"
			echo "------------------------"
			local first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
			local last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")

			# Сгенерируйте 5 случайных имен пользователей
			for i in {1..5}; do
				local first_name_index=$((RANDOM % ${#first_names[@]}))
				local last_name_index=$((RANDOM % ${#last_names[@]}))
				local user_name="${first_names[$first_name_index]} ${last_names[$last_name_index]}"
				echo "Случайное имя пользователя$i: $user_name"
			done

			echo ""
			echo "Случайный UUID"
			echo "------------------------"
			for i in {1..5}; do
				uuid=$(cat /proc/sys/kernel/random/uuid)
				echo "Случайный UUID$i: $uuid"
			done

			echo ""
			echo "16-значный случайный пароль"
			echo "------------------------"
			for i in {1..5}; do
				local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
				echo "случайный пароль$i: $password"
			done

			echo ""
			echo "32-битный случайный пароль"
			echo "------------------------"
			for i in {1..5}; do
				local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
				echo "случайный пароль$i: $password"
			done
			echo ""

			  ;;

		  15)
			root_use
			send_stats "Изменить часовой пояс"
			while true; do
				clear
				echo "Информация о системном времени"

				# Получить текущий часовой пояс системы
				local timezone=$(current_timezone)

				# Получить текущее системное время
				local current_time=$(date +"%Y-%m-%d %H:%M:%S")

				# Показать часовой пояс и время
				echo "Текущий часовой пояс системы:$timezone"
				echo "Текущее системное время:$current_time"

				echo ""
				echo "переключатель часового пояса"
				echo "------------------------"
				echo "Азия"
				echo "1. Шанхай, время Китая 2. Время Гонконга, Китай"
				echo "3. Токио, время Японии 4. Сеул, время Южной Кореи"
				echo "5. Сингапурское время 6. Калькутта, индийское время"
				echo "7. Дубай, время Объединенных Арабских Эмиратов 8. Сидней, время Австралии"
				echo "9. Бангкок, время Таиланда."
				echo "------------------------"
				echo "Европа"
				echo "11. Лондон, время Великобритании. 12. Париж, время Франции."
				echo "13. Берлинское время, Германия 14. Московское время, Россия."
				echo "15. Время Утрахта, Нидерланды 16. Время Мадрида, Испания."
				echo "------------------------"
				echo "Америка"
				echo "21. Западное время США 22. Восточное время США"
				echo "23. Время Канады 24. Время Мексики"
				echo "25. Время Бразилии 26. Время Аргентины"
				echo "------------------------"
				echo "31. Глобальное стандартное время UTC."
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Пожалуйста, введите ваш выбор:" sub_choice


				case $sub_choice in
					1) set_timedate Asia/Shanghai ;;
					2) set_timedate Asia/Hong_Kong ;;
					3) set_timedate Asia/Tokyo ;;
					4) set_timedate Asia/Seoul ;;
					5) set_timedate Asia/Singapore ;;
					6) set_timedate Asia/Kolkata ;;
					7) set_timedate Asia/Dubai ;;
					8) set_timedate Australia/Sydney ;;
					9) set_timedate Asia/Bangkok ;;
					11) set_timedate Europe/London ;;
					12) set_timedate Europe/Paris ;;
					13) set_timedate Europe/Berlin ;;
					14) set_timedate Europe/Moscow ;;
					15) set_timedate Europe/Amsterdam ;;
					16) set_timedate Europe/Madrid ;;
					21) set_timedate America/Los_Angeles ;;
					22) set_timedate America/New_York ;;
					23) set_timedate America/Vancouver ;;
					24) set_timedate America/Mexico_City ;;
					25) set_timedate America/Sao_Paulo ;;
					26) set_timedate America/Argentina/Buenos_Aires ;;
					31) set_timedate UTC ;;
					*) break ;;
				esac
			done
			  ;;

		  16)

			bbrv3
			  ;;

		  17)
			  iptables_panel

			  ;;

		  18)
		  root_use
		  send_stats "Изменить имя хоста"

		  while true; do
			  clear
			  local current_hostname=$(uname -n)
			  echo -e "Текущее имя хоста:${gl_huang}$current_hostname${gl_bai}"
			  echo "------------------------"
			  read -e -p "Пожалуйста, введите новое имя хоста (введите 0 для выхода):" new_hostname
			  if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
				  if [ -f /etc/alpine-release ]; then
					  # Alpine
					  echo "$new_hostname" > /etc/hostname
					  hostname "$new_hostname"
				  else
					  # Другие системы, такие как Debian, Ubuntu, CentOS и т. д.
					  hostnamectl set-hostname "$new_hostname"
					  sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
					  systemctl restart systemd-hostnamed
				  fi

				  if grep -q "127.0.0.1" /etc/hosts; then
					  sed -i "s/127.0.0.1 .*/127.0.0.1       $new_hostname localhost localhost.localdomain/g" /etc/hosts
				  else
					  echo "127.0.0.1       $new_hostname localhost localhost.localdomain" >> /etc/hosts
				  fi

				  if grep -q "^::1" /etc/hosts; then
					  sed -i "s/^::1 .*/::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback/g" /etc/hosts
				  else
					  echo "::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback" >> /etc/hosts
				  fi

				  echo "Имя хоста было изменено на:$new_hostname"
				  send_stats "Имя хоста изменено"
				  sleep 1
			  else
				  echo "Вышел без изменения имени хоста."
				  break
			  fi
		  done
			  ;;

		  19)
		  root_use
		  send_stats "Изменить источник обновлений системы"
		  clear
		  echo "Выберите регион источника обновлений"
		  echo "Доступ к LinuxMirrors для переключения источников обновлений системы."
		  echo "------------------------"
		  echo "1. Материковый Китай [по умолчанию] 2. Материковый Китай [Образовательная сеть] 3. Зарубежные регионы 4. Интеллектуальное переключение источников обновлений"
		  echo "------------------------"
		  echo "0. Вернуться в предыдущее меню"
		  echo "------------------------"
		  read -e -p "Введите свой выбор:" choice

		  case $choice in
			  1)
				  send_stats "Источник по умолчанию для материкового Китая"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh)
				  ;;
			  2)
				  send_stats "Источник образования в материковом Китае"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh) --edu
				  ;;
			  3)
				  send_stats "Зарубежные источники"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
				  ;;
			  4)
				  send_stats "Интеллектуальное переключение источников обновлений"
				  switch_mirror false false
				  ;;

			  *)
				  echo "Отменено"
				  ;;

		  esac

			  ;;

		  20)
		  send_stats "Управление запланированными задачами"
			  while true; do
				  clear
				  check_crontab_installed
				  clear
				  echo "Список запланированных задач"
				  crontab -l
				  echo ""
				  echo "действовать"
				  echo "------------------------"
				  echo "1. Добавить запланированное задание 2. Удалить запланированное задание 3. Изменить запланированное задание"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

				  case $sub_choice in
					  1)
						  read -e -p "Введите команду выполнения новой задачи:" newquest
						  echo "------------------------"
						  echo "1. Ежемесячные задания 2. Еженедельные задания"
						  echo "3. Ежедневные задания 4. Почасовые задания"
						  echo "------------------------"
						  read -e -p "Пожалуйста, введите ваш выбор:" dingshi

						  case $dingshi in
							  1)
								  read -e -p "В какой день месяца вы выбираете выполнение задачи? (1-30):" day
								  (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  2)
								  read -e -p "Выбрать день недели для выполнения задания? (0-6, 0 представляет воскресенье):" weekday
								  (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  3)
								  read -e -p "Какое время вы выбираете для выполнения задания каждый день? (часы, 0-23):" hour
								  (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  4)
								  read -e -p "Введите, в какое время часа должна быть выполнена задача? (минуты, 0-60):" minute
								  (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  *)
								  break  # 跳出
								  ;;
						  esac
						  send_stats "Добавить запланированную задачу"
						  ;;
					  2)
						  read -e -p "Введите ключевое слово задачи, которую необходимо удалить:" kquest
						  crontab -l | grep -v "$kquest" | crontab -
						  send_stats "Удалить запланированные задачи"
						  ;;
					  3)
						  crontab -e
						  send_stats "Редактировать запланированные задачи"
						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done

			  ;;

		  21)
			  root_use
			  send_stats "Разрешение локального хоста"
			  while true; do
				  clear
				  echo "Список разрешений собственных хостов"
				  echo "Если вы добавите сюда сопоставление синтаксического анализа, динамический синтаксический анализ больше не будет использоваться."
				  cat /etc/hosts
				  echo ""
				  echo "действовать"
				  echo "------------------------"
				  echo "1. Добавить новое разрешение 2. Удалить адрес разрешения"
				  echo "------------------------"
				  echo "0. Вернуться в предыдущее меню"
				  echo "------------------------"
				  read -e -p "Пожалуйста, введите ваш выбор:" host_dns

				  case $host_dns in
					  1)
						  read -e -p "Пожалуйста, введите новый формат записи синтаксического анализа: 110.25.5.33 kejilion.pro:" addhost
						  echo "$addhost" >> /etc/hosts
						  send_stats "Добавлено разрешение локального хоста"

						  ;;
					  2)
						  read -e -p "Пожалуйста, введите ключевые слова проанализированного контента, который необходимо удалить:" delhost
						  sed -i "/$delhost/d" /etc/hosts
						  send_stats "Разрешение и удаление локального хоста"
						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;

		  22)
			fail2ban_panel
			  ;;


		  23)
			root_use
			send_stats "Функция отключения по ограничению тока"
			while true; do
				clear
				echo "Функция отключения по ограничению тока"
				echo "Видео-знакомство: https://www.bilibili.com/video/BV1mC411j7Qd?t=0.1"
				echo "------------------------------------------------"
				echo "Текущее использование трафика будет очищено при перезапуске сервера!"
				output_status
				echo -e "${gl_kjlan}Всего получено:${gl_bai}$rx"
				echo -e "${gl_kjlan}Всего отправлено:${gl_bai}$tx"

				# Проверьте, существует ли файл Limiting_Shut_down.sh.
				if [ -f ~/Limiting_Shut_down.sh ]; then
					# Получите значение порога_gb
					local rx_threshold_gb=$(grep -oP 'rx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					local tx_threshold_gb=$(grep -oP 'tx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					echo -e "${gl_lv}В настоящее время установлен порог ограничения входящего трафика:${gl_huang}${rx_threshold_gb}${gl_lv}G${gl_bai}"
					echo -e "${gl_lv}На данный момент установлен порог ограничения исходящего трафика:${gl_huang}${tx_threshold_gb}${gl_lv}GB${gl_bai}"
				else
					echo -e "${gl_hui}Функция отключения по ограничению тока в настоящее время не активирована.${gl_bai}"
				fi

				echo
				echo "------------------------------------------------"
				echo "Система будет определять, достигает ли фактический трафик порогового значения каждую минуту, и автоматически отключит сервер после достижения порогового значения!"
				echo "------------------------"
				echo "1. Включите функцию отключения по ограничению тока. 2. Отключите функцию отключения по ограничению тока."
				echo "------------------------"
				echo "0. Вернуться в предыдущее меню"
				echo "------------------------"
				read -e -p "Пожалуйста, введите ваш выбор:" Limiting

				case "$Limiting" in
				  1)
					# Введите новый размер виртуальной памяти
					echo "Если фактический сервер имеет трафик только 100 ГБ, вы можете установить пороговое значение 95 ГБ и отключить его заранее, чтобы избежать ошибок трафика или переполнения."
					read -e -p "Введите порог входящего трафика (единица измерения — G, по умолчанию — 100G):" rx_threshold_gb
					rx_threshold_gb=${rx_threshold_gb:-100}
					read -e -p "Введите порог исходящего трафика (единица измерения — G, по умолчанию — 100G):" tx_threshold_gb
					tx_threshold_gb=${tx_threshold_gb:-100}
					read -e -p "Введите дату сброса трафика (по умолчанию сбрасывается 1-го числа каждого месяца):" cz_day
					cz_day=${cz_day:-1}

					cd ~
					curl -Ss -o ~/Limiting_Shut_down.sh ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/Limiting_Shut_down1.sh
					chmod +x ~/Limiting_Shut_down.sh
					sed -i "s/110/$rx_threshold_gb/g" ~/Limiting_Shut_down.sh
					sed -i "s/120/$tx_threshold_gb/g" ~/Limiting_Shut_down.sh
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					(crontab -l ; echo "* * * * * ~/Limiting_Shut_down.sh") | crontab - > /dev/null 2>&1
					crontab -l | grep -v 'reboot' | crontab -
					(crontab -l ; echo "0 1 $cz_day * * reboot") | crontab - > /dev/null 2>&1
					echo "Установлено отключение по ограничению тока."
					send_stats "Установлено отключение по ограничению тока."
					;;
				  2)
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					crontab -l | grep -v 'reboot' | crontab -
					rm ~/Limiting_Shut_down.sh
					echo "Функция отключения ограничения тока отключена"
					;;
				  *)
					break
					;;
				esac
			done
			  ;;


		  24)
			sshkey_panel
			  ;;

		  25)
			  root_use
			  send_stats "Телеграфное предупреждение"
			  echo "Мониторинг TG-bot и функция раннего предупреждения"
			  echo "Видео-знакомство: https://youtu.be/vLL-eb3Z_TY"
			  echo "------------------------------------------------"
			  echo "Вам необходимо настроить API-интерфейс tg robot и идентификатор пользователя для получения оповещений для обеспечения мониторинга в реальном времени и оповещений о локальном процессоре, памяти, жестком диске, трафике и входе в SSH."
			  echo "При достижении порога пользователю будет отправлено предупреждающее сообщение."
			  echo -e "${gl_hui}- Что касается трафика, перезапуск сервера приведет к перерасчету -${gl_bai}"
			  read -e -p "Вы уверены, что хотите продолжить? (Да/Нет):" choice

			  case "$choice" in
				[Yy])
				  send_stats "Предупреждение в Telegram включено"
				  cd ~
				  install nano tmux bc jq
				  check_crontab_installed
				  if [ -f ~/TG-check-notify.sh ]; then
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  else
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/TG-check-notify.sh
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  fi
				  tmux kill-session -t TG-check-notify > /dev/null 2>&1
				  tmux new -d -s TG-check-notify "~/TG-check-notify.sh"
				  crontab -l | grep -v '~/TG-check-notify.sh' | crontab - > /dev/null 2>&1
				  (crontab -l ; echo "@reboot tmux new -d -s TG-check-notify '~/TG-check-notify.sh'") | crontab - > /dev/null 2>&1

				  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "3i$(grep '^TELEGRAM_BOT_TOKEN=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "4i$(grep '^CHAT_ID=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh
				  chmod +x ~/TG-SSH-check-notify.sh

				  # Добавить в файл ~/.profile
				  if ! grep -q 'bash ~/TG-SSH-check-notify.sh' ~/.profile > /dev/null 2>&1; then
					  echo 'bash ~/TG-SSH-check-notify.sh' >> ~/.profile
					  if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
						 echo 'source ~/.profile' >> ~/.bashrc
					  fi
				  fi

				  source ~/.profile

				  clear
				  echo "Активирована система раннего оповещения TG-bot"
				  echo -e "${gl_hui}Вы также можете поместить файл предупреждения TG-check-notify.sh в корневой каталог на других машинах и использовать его напрямую!${gl_bai}"
				  ;;
				[Nn])
				  echo "Отменено"
				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac
			  ;;

		  26)
			  root_use
			  send_stats "Исправьте уязвимости SSH высокого риска."
			  cd ~
			  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/upgrade_openssh9.8p1.sh
			  chmod +x ~/upgrade_openssh9.8p1.sh
			  ~/upgrade_openssh9.8p1.sh
			  rm -f ~/upgrade_openssh9.8p1.sh
			  ;;

		  27)
			  elrepo
			  ;;
		  28)
			  Kernel_optimize
			  ;;

		  29)
			  clamav
			  ;;

		  30)
			  linux_file
			  ;;

		  31)
			  linux_language
			  ;;

		  32)
			  shell_bianse
			  ;;
		  33)
			  linux_trash
			  ;;
		  34)
			  linux_backup
			  ;;
		  35)
			  ssh_manager
			  ;;
		  36)
			  disk_manager
			  ;;
		  37)
			  clear
			  send_stats "История командной строки"
			  get_history_file() {
				  for file in "$HOME"/.bash_history "$HOME"/.ash_history "$HOME"/.zsh_history "$HOME"/.local/share/fish/fish_history; do
					  [ -f "$file" ] && { echo "$file"; return; }
				  done
				  return 1
			  }

			  history_file=$(get_history_file) && cat -n "$history_file"
			  ;;

		  38)
			  rsync_manager
			  ;;


		  39)
			  clear
			  linux_fav
			  ;;

		  40)
			  clear
			  net_menu
			  ;;

		  41)
			  clear
			  log_menu
			  ;;

		  42)
			  clear
			  env_menu
			  ;;


		  61)
			clear
			send_stats "доска объявлений"
			echo "Посетите официальную доску объявлений Technology Lion. Если у вас есть идеи по поводу сценария, оставьте сообщение для обмена!"
			echo "https://board.kejilion.pro"
			echo "Публичный пароль: kejilion.sh"
			  ;;

		  66)

			  root_use
			  send_stats "Универсальная настройка"
			  echo "Универсальная настройка системы"
			  echo "------------------------------------------------"
			  echo "Следующий контент будет работать и оптимизироваться"
			  echo "1. Оптимизируйте источник обновлений системы и обновите систему до последней версии."
			  echo "2. Очистите системные ненужные файлы."
			  echo -e "3. Настройте виртуальную память.${gl_huang}1G${gl_bai}"
			  echo -e "4. Установите номер порта SSH на${gl_huang}5522${gl_bai}"
			  echo -e "5. Запустите Fail2ban для защиты от грубого взлома SSH."
			  echo -e "6. Откройте все порты"
			  echo -e "7. Включите${gl_huang}BBR${gl_bai}ускоряться"
			  echo -e "8. Установите часовой пояс на${gl_huang}Шанхай${gl_bai}"
			  echo -e "9. Автоматическая оптимизация DNS-адресов${gl_huang}За рубежом: 1.1.1.1 8.8.8.8 Внутри страны: 223.5.5.5${gl_bai}"
		  	  echo -e "10. Установите сеть на${gl_huang}приоритет ipv4${gl_bai}"
			  echo -e "11. Установите основные инструменты${gl_huang}docker wget sudo tar unzip socat btop nano vim${gl_bai}"
			  echo -e "12. Оптимизация параметров ядра системы Linux переключается на${gl_huang}Режим сбалансированной оптимизации${gl_bai}"
			  echo "------------------------------------------------"
			  read -e -p "Вы уверены, что хотите обслуживание в один клик? (Да/Нет):" choice

			  case "$choice" in
				[Yy])
				  clear
				  send_stats "Начало комплексной настройки"
				  echo "------------------------------------------------"
				  switch_mirror false false
				  linux_update
				  echo -e "[${gl_lv}OK${gl_bai}] 1/12. Обновите систему до последней версии"

				  echo "------------------------------------------------"
				  linux_clean
				  echo -e "[${gl_lv}OK${gl_bai}] 2/12. Очистите системные ненужные файлы"

				  echo "------------------------------------------------"
				  add_swap 1024
				  echo -e "[${gl_lv}OK${gl_bai}] 3/12. Настройка виртуальной памяти${gl_huang}1G${gl_bai}"

				  echo "------------------------------------------------"
				  new_ssh_port 5522
				  echo -e "[${gl_lv}OK${gl_bai}] 4/12. Установите номер порта SSH на${gl_huang}5522${gl_bai}"
				  echo "------------------------------------------------"
				  f2b_install_sshd
				  cd ~
				  f2b_status
				  echo -e "[${gl_lv}OK${gl_bai}] 5/12. Запустите Fail2ban для защиты от грубого взлома SSH."

				  echo "------------------------------------------------"
				  echo -e "[${gl_lv}OK${gl_bai}] 12.06. Открыть все порты"

				  echo "------------------------------------------------"
				  bbr_on
				  echo -e "[${gl_lv}OK${gl_bai}] 7/12. Открыть${gl_huang}BBR${gl_bai}ускоряться"

				  echo "------------------------------------------------"
				  set_timedate Asia/Shanghai
				  echo -e "[${gl_lv}OK${gl_bai}] 8/12. Установите часовой пояс на${gl_huang}Шанхай${gl_bai}"

				  echo "------------------------------------------------"
				  auto_optimize_dns
				  echo -e "[${gl_lv}OK${gl_bai}] 9/12. Автоматически оптимизировать DNS-адрес${gl_huang}${gl_bai}"
				  echo "------------------------------------------------"
				  prefer_ipv4
				  echo -e "[${gl_lv}OK${gl_bai}] 10/12. Установите сеть на${gl_huang}приоритет ipv4${gl_bai}}"

				  echo "------------------------------------------------"
				  install_docker
				  install wget sudo tar unzip socat btop nano vim
				  echo -e "[${gl_lv}OK${gl_bai}] 11/12. Установите базовые инструменты${gl_huang}docker wget sudo tar unzip socat btop nano vim${gl_bai}"
				  echo "------------------------------------------------"

				  optimize_balanced
				  echo -e "[${gl_lv}OK${gl_bai}] 12/12. Оптимизация параметров ядра системы Linux"
				  echo -e "${gl_lv}Комплексная настройка системы завершена.${gl_bai}"

				  ;;
				[Nn])
				  echo "Отменено"
				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac

			  ;;

		  99)
			  clear
			  send_stats "Перезагрузите систему"
			  server_reboot
			  ;;
		  100)

			root_use
			while true; do
			  clear
			  if grep -q '^ENABLE_STATS="true"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_lv}Сбор данных${gl_bai}"
			  elif grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_hui}Коллекция закрыта${gl_bai}"
			  else
			  	local status_message="Неопределенный статус"
			  fi

			  echo "Конфиденциальность и безопасность"
			  echo "Скрипт будет собирать данные об использовании функций пользователями, оптимизировать работу со скриптом и создавать больше интересных и полезных функций."
			  echo "Будут собраны номер версии сценария, время использования, версия системы, архитектура ЦП, страна машины и название используемой функции."
			  echo "------------------------------------------------"
			  echo -e "Текущий статус:$status_message"
			  echo "--------------------"
			  echo "1. Начать сбор"
			  echo "2. Закрыть сбор"
			  echo "--------------------"
			  echo "0. Вернуться в предыдущее меню"
			  echo "--------------------"
			  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice
			  case $sub_choice in
				  1)
					  cd ~
					  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' /usr/local/bin/k
					  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' ~/kejilion.sh
					  echo "Сбор начался"
					  send_stats "Сбор данных о конфиденциальности и безопасности включен."
					  ;;
				  2)
					  cd ~
					  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/k
					  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/kejilion.sh
					  echo "Коллекция закрыта"
					  send_stats "Сбор данных о конфиденциальности и безопасности отключен."
					  ;;
				  *)
					  break
					  ;;
			  esac
			done
			  ;;

		  101)
			  clear
			  k_info
			  ;;

		  102)
			  clear
			  send_stats "Удалить скрипт технологического льва"
			  echo "Удалить скрипт технологического льва"
			  echo "------------------------------------------------"
			  echo "Скрипт kejilion будет полностью удален, не затрагивая другие ваши функции."
			  read -e -p "Вы уверены, что хотите продолжить? (Да/Нет):" choice

			  case "$choice" in
				[Yy])
				  clear
				  (crontab -l | grep -v "kejilion.sh") | crontab -
				  rm -f /usr/local/bin/k
				  rm ~/kejilion.sh
				  echo "Скрипт удален, до свидания!"
				  break_end
				  clear
				  exit
				  ;;
				[Nn])
				  echo "Отменено"
				  ;;
				*)
				  echo "Неверный выбор, введите Y или N."
				  ;;
			  esac
			  ;;

		  0)
			  kejilion

			  ;;
		  *)
			  echo "Неверный ввод!"
			  ;;
	  esac
	  break_end

	done



}






linux_file() {
	root_use
	send_stats "файловый менеджер"
	while true; do
		clear
		echo "файловый менеджер"
		echo "------------------------"
		echo "текущий путь"
		pwd
		echo "------------------------"
		ls --color=auto -x
		echo "------------------------"
		echo "1. Введите каталог 2. Создайте каталог 3. Измените права доступа к каталогу 4. Переименуйте каталог"
		echo "5. Удалить каталог 6. Вернуться в предыдущий каталог меню"
		echo "------------------------"
		echo "11. Создание файлов 12. Редактирование файлов 13. Изменение разрешений файлов 14. Переименование файлов"
		echo "15. Удалить файлы"
		echo "------------------------"
		echo "21. Сжать каталог файлов 22. Разархивировать каталог файлов 23. Переместить каталог файлов 24. Скопировать каталог файлов"
		echo "25. Перенос файлов на другие серверы"
		echo "------------------------"
		echo "0. Вернуться в предыдущее меню"
		echo "------------------------"
		read -e -p "Пожалуйста, введите ваш выбор:" Limiting

		case "$Limiting" in
			1)  # 进入目录
				read -e -p "Пожалуйста, введите имя каталога:" dirname
				cd "$dirname" 2>/dev/null || echo "Невозможно войти в каталог"
				send_stats "Введите каталог"
				;;
			2)  # 创建目录
				read -e -p "Введите имя создаваемого каталога:" dirname
				mkdir -p "$dirname" && echo "Каталог создан" || echo "Не удалось создать"
				send_stats "Создать каталог"
				;;
			3)  # 修改目录权限
				read -e -p "Пожалуйста, введите имя каталога:" dirname
				read -e -p "Введите разрешения (например, 755):" perm
				chmod "$perm" "$dirname" && echo "Разрешения были изменены" || echo "Модификация не удалась"
				send_stats "Изменить права доступа к каталогу"
				;;
			4)  # 重命名目录
				read -e -p "Пожалуйста, введите имя текущего каталога:" current_name
				read -e -p "Пожалуйста, введите новое имя каталога:" new_name
				mv "$current_name" "$new_name" && echo "Каталог переименован" || echo "Переименование не удалось"
				send_stats "Переименовать каталог"
				;;
			5)  # 删除目录
				read -e -p "Пожалуйста, введите имя каталога, который нужно удалить:" dirname
				rm -rf "$dirname" && echo "Каталог удален." || echo "Удаление не удалось"
				send_stats "удалить каталог"
				;;
			6)  # 返回上一级选单目录
				cd ..
				send_stats "Вернуться в предыдущую директорию меню"
				;;
			11) # 创建文件
				read -e -p "Введите имя файла, который необходимо создать:" filename
				touch "$filename" && echo "Файл создан" || echo "Не удалось создать"
				send_stats "Создать файл"
				;;
			12) # 编辑文件
				read -e -p "Пожалуйста, введите имя файла для редактирования:" filename
				install nano
				nano "$filename"
				send_stats "Редактировать файл"
				;;
			13) # 修改文件权限
				read -e -p "Пожалуйста, введите имя файла:" filename
				read -e -p "Введите разрешения (например, 755):" perm
				chmod "$perm" "$filename" && echo "Разрешения были изменены" || echo "Модификация не удалась"
				send_stats "Изменить права доступа к файлу"
				;;
			14) # 重命名文件
				read -e -p "Пожалуйста, введите текущее имя файла:" current_name
				read -e -p "Пожалуйста, введите новое имя файла:" new_name
				mv "$current_name" "$new_name" && echo "Файл переименован" || echo "Переименование не удалось"
				send_stats "Переименовать файл"
				;;
			15) # 删除文件
				read -e -p "Пожалуйста, введите имя файла, который необходимо удалить:" filename
				rm -f "$filename" && echo "Файл удален" || echo "Удаление не удалось"
				send_stats "Удалить файлы"
				;;
			21) # 压缩文件/目录
				read -e -p "Пожалуйста, введите имя файла/каталога для сжатия:" name
				install tar
				tar -czvf "$name.tar.gz" "$name" && echo "Сжат до$name.tar.gz" || echo "Сжатие не удалось"
				send_stats "Сжатые файлы/каталоги"
				;;
			22) # 解压文件/目录
				read -e -p "Пожалуйста, введите имя файла для извлечения (.tar.gz):" filename
				install tar
				tar -xzvf "$filename" && echo "Разархивированный$filename" || echo "Декомпрессия не удалась"
				send_stats "Разархивируйте файлы/каталоги"
				;;

			23) # 移动文件或目录
				read -e -p "Пожалуйста, введите путь к файлу или каталогу, который необходимо переместить:" src_path
				if [ ! -e "$src_path" ]; then
					echo "Ошибка: Файл или каталог не существует."
					send_stats "Не удалось переместить файл или каталог: файл или каталог не существует."
					continue
				fi

				read -e -p "Введите путь назначения (включая имя нового файла или каталога):" dest_path
				if [ -z "$dest_path" ]; then
					echo "Ошибка: введите путь назначения."
					send_stats "Не удалось переместить файл или каталог: не указан путь назначения."
					continue
				fi

				mv "$src_path" "$dest_path" && echo "Файл или каталог перемещен в$dest_path" || echo "Не удалось переместить файл или каталог"
				send_stats "Переместить файл или каталог"
				;;


		   24) # 复制文件目录
				read -e -p "Пожалуйста, введите путь к файлу или каталогу для копирования:" src_path
				if [ ! -e "$src_path" ]; then
					echo "Ошибка: Файл или каталог не существует."
					send_stats "Не удалось скопировать файл или каталог: файл или каталог не существует."
					continue
				fi

				read -e -p "Введите путь назначения (включая имя нового файла или каталога):" dest_path
				if [ -z "$dest_path" ]; then
					echo "Ошибка: введите путь назначения."
					send_stats "Не удалось скопировать файл или каталог: не указан путь назначения."
					continue
				fi

				# Используйте опцию -r для рекурсивного копирования каталогов.
				cp -r "$src_path" "$dest_path" && echo "Файл или каталог скопирован в$dest_path" || echo "Не удалось скопировать файл или каталог"
				send_stats "Скопируйте файл или каталог"
				;;


			 25) # 传送文件至远端服务器
				read -e -p "Пожалуйста, введите путь к файлу для передачи:" file_to_transfer
				if [ ! -f "$file_to_transfer" ]; then
					echo "Ошибка: Файл не существует."
					send_stats "Не удалось передать файл: файл не существует."
					continue
				fi

				read -e -p "Пожалуйста, введите IP-адрес удаленного сервера:" remote_ip
				if [ -z "$remote_ip" ]; then
					echo "Ошибка: введите IP-адрес удаленного сервера."
					send_stats "Передача файла не удалась: IP-адрес удаленного сервера не введен."
					continue
				fi

				read -e -p "Пожалуйста, введите имя пользователя удаленного сервера (по умолчанию root):" remote_user
				remote_user=${remote_user:-root}

				read -e -p "Пожалуйста, введите пароль удаленного сервера:" -s remote_password
				echo
				if [ -z "$remote_password" ]; then
					echo "Ошибка: введите пароль удаленного сервера."
					send_stats "Передача файла не удалась: не введен пароль удаленного сервера."
					continue
				fi

				read -e -p "Пожалуйста, введите порт входа (по умолчанию 22):" remote_port
				remote_port=${remote_port:-22}

				# Очистить старые записи для известных хостов
				ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
				sleep 2  # 等待时间

				# Перенос файлов с помощью scp
				scp -P "$remote_port" -o StrictHostKeyChecking=no "$file_to_transfer" "$remote_user@$remote_ip:/home/" <<EOF
$remote_password
EOF

				if [ $? -eq 0 ]; then
					echo "Файл был перенесен в домашний каталог удаленного сервера."
					send_stats "Передача файла прошла успешно"
				else
					echo "Передача файла не удалась."
					send_stats "Передача файла не удалась"
				fi

				break_end
				;;



			0)  # 返回上一级选单
				send_stats "Вернуться в предыдущее меню"
				break
				;;
			*)  # 处理无效输入
				echo "Неверный выбор, пожалуйста, введите еще раз"
				send_stats "Неверный выбор"
				;;
		esac
	done
}






cluster_python3() {
	install python3 python3-paramiko
	cd ~/cluster/
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/python-for-vps/main/cluster/$py_task
	python3 ~/cluster/$py_task
}


run_commands_on_servers() {

	install sshpass

	local SERVERS_FILE="$HOME/cluster/servers.py"
	local SERVERS=$(grep -oP '{"name": "\K[^"]+|"hostname": "\K[^"]+|"port": \K[^,]+|"username": "\K[^"]+|"password": "\K[^"]+' "$SERVERS_FILE")

	# Преобразуйте извлеченную информацию в массив
	IFS=$'\n' read -r -d '' -a SERVER_ARRAY <<< "$SERVERS"

	# Обход сервера и выполнение команд
	for ((i=0; i<${#SERVER_ARRAY[@]}; i+=5)); do
		local name=${SERVER_ARRAY[i]}
		local hostname=${SERVER_ARRAY[i+1]}
		local port=${SERVER_ARRAY[i+2]}
		local username=${SERVER_ARRAY[i+3]}
		local password=${SERVER_ARRAY[i+4]}
		echo
		echo -e "${gl_huang}Подключиться к$name ($hostname)...${gl_bai}"
		# sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
		sshpass -p "$password" ssh -t -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
	done
	echo
	break_end

}


linux_cluster() {
mkdir cluster
if [ ! -f ~/cluster/servers.py ]; then
	cat > ~/cluster/servers.py << EOF
servers = [

]
EOF
fi

while true; do
	  clear
	  send_stats "Центр управления кластером"
	  echo "Управление кластером серверов"
	  cat ~/cluster/servers.py
	  echo
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}Управление списком серверов${gl_bai}"
	  echo -e "${gl_kjlan}1.  ${gl_bai}Добавить сервер${gl_kjlan}2.  ${gl_bai}Удалить сервер${gl_kjlan}3.  ${gl_bai}Редактировать сервер"
	  echo -e "${gl_kjlan}4.  ${gl_bai}Резервный кластер${gl_kjlan}5.  ${gl_bai}Восстановить кластер"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}Пакетное выполнение задач${gl_bai}"
	  echo -e "${gl_kjlan}11. ${gl_bai}Установить скрипт технологического льва${gl_kjlan}12. ${gl_bai}Обновление системы${gl_kjlan}13. ${gl_bai}Очистите систему"
	  echo -e "${gl_kjlan}14. ${gl_bai}Установить докер${gl_kjlan}15. ${gl_bai}Установить ББР3${gl_kjlan}16. ${gl_bai}Установить виртуальную память 1 ГБ"
	  echo -e "${gl_kjlan}17. ${gl_bai}Установить часовой пояс Шанхай${gl_kjlan}18. ${gl_bai}Открыть все порты${gl_kjlan}51. ${gl_bai}пользовательская директива"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}0.  ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in
		  1)
			  send_stats "Добавить сервер кластера"
			  read -e -p "Имя сервера:" server_name
			  read -e -p "IP сервера:" server_ip
			  read -e -p "Порт сервера (22):" server_port
			  local server_port=${server_port:-22}
			  read -e -p "Имя пользователя сервера (root):" server_username
			  local server_username=${server_username:-root}
			  read -e -p "Пароль пользователя сервера:" server_password

			  sed -i "/servers = \[/a\    {\"name\": \"$server_name\", \"hostname\": \"$server_ip\", \"port\": $server_port, \"username\": \"$server_username\", \"password\": \"$server_password\", \"remote_path\": \"/home/\"}," ~/cluster/servers.py

			  ;;
		  2)
			  send_stats "Удалить сервер кластера"
			  read -e -p "Пожалуйста, введите ключевые слова, которые необходимо удалить:" rmserver
			  sed -i "/$rmserver/d" ~/cluster/servers.py
			  ;;
		  3)
			  send_stats "Изменить сервер кластера"
			  install nano
			  nano ~/cluster/servers.py
			  ;;

		  4)
			  clear
			  send_stats "Резервный кластер"
			  echo -e "пожалуйста, измените${gl_huang}/root/cluster/servers.py${gl_bai}Загрузите файл и завершите резервное копирование!"
			  break_end
			  ;;

		  5)
			  clear
			  send_stats "Восстановить кластер"
			  echo "Пожалуйста, загрузите свой файл server.py и нажмите любую клавишу, чтобы начать загрузку!"
			  echo -e "Пожалуйста, загрузите свой${gl_huang}servers.py${gl_bai}файл в${gl_huang}/root/cluster/${gl_bai}Восстановление завершено!"
			  break_end
			  ;;

		  11)
			  local py_task="install_kejilion.py"
			  cluster_python3
			  ;;
		  12)
			  run_commands_on_servers "k update"
			  ;;
		  13)
			  run_commands_on_servers "k clean"
			  ;;
		  14)
			  run_commands_on_servers "k docker install"
			  ;;
		  15)
			  run_commands_on_servers "k bbr3"
			  ;;
		  16)
			  run_commands_on_servers "k swap 1024"
			  ;;
		  17)
			  run_commands_on_servers "k time Asia/Shanghai"
			  ;;
		  18)
			  run_commands_on_servers "k iptables_open"
			  ;;

		  51)
			  send_stats "Пользовательская команда выполнения"
			  read -e -p "Введите команду для пакетного выполнения:" mingling
			  run_commands_on_servers "${mingling}"
			  ;;

		  *)
			  kejilion
			  ;;
	  esac
done

}




kejilion_Affiliates() {

clear
send_stats "Рекламная колонка"
echo "Рекламная колонка"
echo "------------------------"
echo "Это предоставит пользователям более простой и элегантный опыт продвижения и покупок!"
echo ""
echo -e "Скидка на сервер"
echo "------------------------"
echo -e "${gl_lan}Laika Cloud Гонконг CN2 GIA Корейский двойной интернет-провайдер Рекламные акции CN2 GIA в США${gl_bai}"
echo -e "${gl_bai}Веб-сайт: https://www.lcayun.com/aff/ZEXUQBIM.${gl_bai}"
echo "------------------------"
echo -e "${gl_lan}RackNerd $10,99 в год, США, 1 ядро, 1 ГБ памяти, 20 ГБ жесткого диска, 1 Т трафика в месяц${gl_bai}"
echo -e "${gl_bai}URL: https://my.racknerd.com/aff.php?aff=5501&pid=879.${gl_bai}"
echo "------------------------"
echo -e "${gl_zi}Hostinger $52,7 в год США 1 ядро ​​4G памяти 50G жесткий диск 4T трафика в месяц${gl_bai}"
echo -e "${gl_bai}URL: https://cart.hostinger.com/pay/d83c51e9-0c28-47a6-8414-b8ab010ef94f?_ga=GA1.3.942352702.1711283207${gl_bai}"
echo "------------------------"
echo -e "${gl_huang}Каменщик 49 долларов в квартал США CN2GIA Япония SoftBank 2 ядра 1 ГБ памяти 20 ГБ жесткого диска 1 Т трафика в месяц${gl_bai}"
echo -e "${gl_bai}Веб-сайт: https://bandwagonhost.com/aff.php?aff=69004&pid=87.${gl_bai}"
echo "------------------------"
echo -e "${gl_lan}DMIT 28 долларов США в квартал, США CN2GIA, 1 ядро, память 2 ГБ, жесткий диск 20 ГБ, трафик 800 ГБ в месяц${gl_bai}"
echo -e "${gl_bai}URL: https://www.dmit.io/aff.php?aff=4966&pid=100.${gl_bai}"
echo "------------------------"
echo -e "${gl_zi}V.PS 6,9 долларов в месяц Tokyo Softbank 2 ядра 1G памяти 20G жесткий диск 1T трафика в месяц${gl_bai}"
echo -e "${gl_bai}URL: https://vps.hosting/cart/tokyo-cloud-kvm-vps/?id=148&?affid=1355&?affid=1355${gl_bai}"
echo "------------------------"
echo -e "${gl_kjlan}Более популярные предложения VPS${gl_bai}"
echo -e "${gl_bai}Сайт: https://kejilion.pro/topvps/${gl_bai}"
echo "------------------------"
echo ""
echo -e "Скидка на доменное имя"
echo "------------------------"
echo -e "${gl_lan}GNAME 8,8 долларов США, доменное имя COM за первый год 6,68 долларов США, доменное имя CC за первый год${gl_bai}"
echo -e "${gl_bai}Веб-сайт: https://www.gname.com/register?tt=86836&ttcode=KEJILION86836&ttbj=sh.${gl_bai}"
echo "------------------------"
echo ""
echo -e "Технологические периферийные устройства льва"
echo "------------------------"
echo -e "${gl_kjlan}Станция Б:${gl_bai}https://b23.tv/2mqnQyh              ${gl_kjlan}Маслопровод:${gl_bai}https://www.youtube.com/@kejilion${gl_bai}"
echo -e "${gl_kjlan}Официальный сайт:${gl_bai}https://kejilion.pro/              ${gl_kjlan}навигация:${gl_bai}https://dh.kejilion.pro/${gl_bai}"
echo -e "${gl_kjlan}блог:${gl_bai}https://blog.kejilion.pro/         ${gl_kjlan}Центр программного обеспечения:${gl_bai}https://app.kejilion.pro/${gl_bai}"
echo "------------------------"
echo -e "${gl_kjlan}Официальный сайт скрипта:${gl_bai}https://kejilion.sh            ${gl_kjlan}Адрес ГитХаба:${gl_bai}${gh_https_url}github.com/kejilion/sh${gl_bai}"
echo "------------------------"
echo ""
}




games_server_tools() {

	while true; do
	  clear
	  echo -e "Сборник скриптов открытия игровых серверов"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1. ${gl_bai}Скрипт открытия сервера Eudemons Parlu"
	  echo -e "${gl_kjlan}2. ${gl_bai}Скрипт открытия сервера Майнкрафт"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0. ${gl_bai}Вернуться в главное меню"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "Пожалуйста, введите ваш выбор:" sub_choice

	  case $sub_choice in

		  1) send_stats "Скрипт открытия сервера Eudemons Parlu" ; cd ~
			 curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/palworld.sh ; chmod +x palworld.sh ; ./palworld.sh
			 exit
			 ;;
		  2) send_stats "Скрипт открытия сервера Майнкрафт" ; cd ~
			 curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/mc.sh ; chmod +x mc.sh ; ./mc.sh
			 exit
			 ;;

		  0)
			kejilion
			;;

		  *)
			echo "Неверный ввод!"
			;;
	  esac
	  break_end

	done


}





















kejilion_update() {

send_stats "Обновление скрипта"
cd ~
while true; do
	clear
	echo "Журнал изменений"
	echo "------------------------"
	echo "Все журналы:${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion_sh_log.txt"
	echo "------------------------"

	curl -s ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion_sh_log.txt | tail -n 30
	local sh_v_new=$(curl -s ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion.sh | grep -o 'sh_v="[0-9.]*"' | cut -d '"' -f 2)

	if [ "$sh_v" = "$sh_v_new" ]; then
		echo -e "${gl_lv}Вы уже используете последнюю версию!${gl_huang}v$sh_v${gl_bai}"
		send_stats "Скрипт уже актуален и не нуждается в обновлении."
	else
		echo "Обнаружена новая версия!"
		echo -e "Текущая версия v$sh_vпоследняя версия${gl_huang}v$sh_v_new${gl_bai}"
	fi


	local cron_job="kejilion.sh"
	local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

	if [ -n "$existing_cron" ]; then
		echo "------------------------"
		echo -e "${gl_lv}Включены автоматические обновления, и скрипт будет автоматически обновляться в 2 часа ночи каждый день!${gl_bai}"
	fi

	echo "------------------------"
	echo "1. Обновить сейчас 2. Включить автоматические обновления 3. Отключить автоматические обновления"
	echo "------------------------"
	echo "0. Вернуться в главное меню"
	echo "------------------------"
	read -e -p "Пожалуйста, введите ваш выбор:" choice
	case "$choice" in
		1)
			clear
			local country=$(curl -s ipinfo.io/country)
			if [ "$country" = "CN" ]; then
				curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/cn/kejilion.sh && chmod +x kejilion.sh
			else
				curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh
			fi
			canshu_v6
			CheckFirstRun_true
			yinsiyuanquan2
			cp -f ~/kejilion.sh /usr/local/bin/k > /dev/null 2>&1
			echo -e "${gl_lv}Скрипт обновлен до последней версии!${gl_huang}v$sh_v_new${gl_bai}"
			send_stats "Скрипт актуален$sh_v_new"
			break_end
			~/kejilion.sh
			exit
			;;
		2)
			clear
			local country=$(curl -s ipinfo.io/country)
			local ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
			if [ "$country" = "CN" ]; then
				SH_Update_task="curl -sS -O https://gh.kejilion.pro/raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh && sed -i 's/canshu=\"default\"/canshu=\"CN\"/g' ./kejilion.sh"
			elif [ -n "$ipv6_address" ]; then
				SH_Update_task="curl -sS -O https://gh.kejilion.pro/raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh && sed -i 's/canshu=\"default\"/canshu=\"V6\"/g' ./kejilion.sh"
			else
				SH_Update_task="curl -sS -O https://raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh"
			fi
			check_crontab_installed
			(crontab -l | grep -v "kejilion.sh") | crontab -
			# (crontab -l 2>/dev/null; echo "0 2 * * * bash -c \"$SH_Update_task\"") | crontab -
			(crontab -l 2>/dev/null; echo "$(shuf -i 0-59 -n 1) 2 * * * bash -c \"$SH_Update_task\"") | crontab -
			echo -e "${gl_lv}Включены автоматические обновления, и скрипт будет автоматически обновляться в 2 часа ночи каждый день!${gl_bai}"
			send_stats "Включить автоматическое обновление скриптов"
			break_end
			;;
		3)
			clear
			(crontab -l | grep -v "kejilion.sh") | crontab -
			echo -e "${gl_lv}Автоматические обновления отключены${gl_bai}"
			send_stats "Отключить автоматическое обновление скриптов"
			break_end
			;;
		*)
			kejilion_sh
			;;
	esac
done

}





kejilion_sh() {
while true; do
clear
echo -e "${gl_kjlan}"
echo "╦╔═╔═╗ ╦╦╦  ╦╔═╗╔╗╔ ╔═╗╦ ╦"
echo "╠╩╗║╣  ║║║  ║║ ║║║║ ╚═╗╠═╣"
echo "╩ ╩╚═╝╚╝╩╩═╝╩╚═╝╝╚╝o╚═╝╩ ╩"
echo -e "Набор инструментов для сценариев Technology Lion v$sh_v"
echo -e "Ввод командной строки${gl_huang}k${gl_kjlan}Скрипт быстрого старта${gl_bai}"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}1.   ${gl_bai}Запрос информации о системе"
echo -e "${gl_kjlan}2.   ${gl_bai}Обновление системы"
echo -e "${gl_kjlan}3.   ${gl_bai}Очистка системы"
echo -e "${gl_kjlan}4.   ${gl_bai}основные инструменты"
echo -e "${gl_kjlan}5.   ${gl_bai}Управление ББР"
echo -e "${gl_kjlan}6.   ${gl_bai}Управление докером"
echo -e "${gl_kjlan}7.   ${gl_bai}Управление варпом"
echo -e "${gl_kjlan}8.   ${gl_bai}Коллекция тестовых сценариев"
echo -e "${gl_kjlan}9.   ${gl_bai}Коллекция сценариев Oracle Cloud"
echo -e "${gl_huang}10.  ${gl_bai}Создание сайта ЛДНМП"
echo -e "${gl_kjlan}11.  ${gl_bai}рынок приложений"
echo -e "${gl_kjlan}12.  ${gl_bai}Серверная рабочая область"
echo -e "${gl_kjlan}13.  ${gl_bai}системные инструменты"
echo -e "${gl_kjlan}14.  ${gl_bai}Управление кластером серверов"
echo -e "${gl_kjlan}15.  ${gl_bai}Рекламная колонка"
echo -e "${gl_kjlan}16.  ${gl_bai}Сборник скриптов открытия игровых серверов"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}00.  ${gl_bai}Обновление скрипта"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}0.   ${gl_bai}Выход из сценария"
echo -e "${gl_kjlan}------------------------${gl_bai}"
read -e -p "Пожалуйста, введите ваш выбор:" choice

case $choice in
  1) linux_info ;;
  2) clear ; send_stats "Обновление системы" ; linux_update ;;
  3) clear ; send_stats "Очистка системы" ; linux_clean ;;
  4) linux_tools ;;
  5) linux_bbr ;;
  6) linux_docker ;;
  7) clear ; send_stats "управление варпом" ; install wget
	wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh ; bash menu.sh [option] [lisence/url/token]
	;;
  8) linux_test ;;
  9) linux_Oracle ;;
  10) linux_ldnmp ;;
  11) linux_panel ;;
  12) linux_work ;;
  13) linux_Settings ;;
  14) linux_cluster ;;
  15) kejilion_Affiliates ;;
  16) games_server_tools ;;
  00) kejilion_update ;;
  0) clear ; exit ;;
  *) echo "Неверный ввод!" ;;
esac
	break_end
done
}


k_info() {
send_stats "k справочные примеры команд"
echo "-------------------"
echo "Видео-знакомство: https://www.bilibili.com/video/BV1ib421E7it?t=0.1"
echo "Ниже приведен пример использования команды k:"
echo "Запустить скрипт k"
echo "Установить пакеты k установить nano wget | k добавить nano wget | установить nano wget"
echo "Удалить пакет k удалить nano wget | к дель нано wget | k удалить nano wget | удалить nano wget"
echo "Обновление системы k обновление | обновление"
echo "Очистить систему от мусора k очистить | к чистоте"
echo "Переустановить системную панель k dd | переустановить"
echo "панель управления bbr3 k bbr3 | к ббрв3"
echo "Панель настройки ядра k nhyh | k Оптимизация ядра"
echo "Установить виртуальную память k swap 2048"
echo "Установить виртуальный часовой пояс k время Азия/Шанхай | k часовой пояс Азия/Шанхай"
echo "Система Recycle Bin k мусор | к хсз | k Корзина"
echo "Функция резервного копирования системы k резервное копирование | к бою | резервная копия"
echo "инструмент удаленного подключения ssh k ssh | к удаленное соединение"
echo "инструмент удаленной синхронизации rsync k rsync | k удаленная синхронизация"
echo "Инструмент управления жестким диском k диск | управление жестким диском"
echo "Проникновение во внутреннюю сеть (сервер) k frps"
echo "Проникновение в интранет (клиент) k frpc"
echo "Запуск программного обеспечения k start sshd | начать sshd"
echo "Программное обеспечение стоп-к-стоп sshd | окей, останови sshd"
echo "Программный перезапуск k перезапуск sshd | перезапустить sshd"
echo "Проверьте статус программного обеспечения k status sshd | статус к sshd"
echo "k включить докер | k автозапуск докера | k включить докер при загрузке программного обеспечения"
echo "Приложение для получения сертификата доменного имени k SSL"
echo "Запрос на истечение срока действия сертификата доменного имени k ssl ps"
echo "плоскость управления Docker K Docker"
echo "установка среды docker k установка docker | установка k docker"
echo "управление контейнером docker k docker ps |k docker-контейнер"
echo "управление образами docker k docker img |k docker image"
echo "Управление сайтом LDNMP в Интернете"
echo "Очистка кэша LDNMP и веб-кеша"
echo "Установите WordPress k wp | к WordPress | к WP xxx.com"
echo "Установить обратный прокси-сервер k fd |k rp |k обратный прокси-сервер |k fd xxx.com"
echo "Установите балансировку нагрузки k loadbalance |k load balancing"
echo "Установите балансировку нагрузки L4 k поток |k балансировку нагрузки L4"
echo "панель брандмауэра k fhq |k брандмауэр"
echo "открыть порт k dkdk 8080 |k открыть порт 8080"
echo "Закрыть порт k gbdk 7800 |k Закрыть порт 7800"
echo "Версия IP k fxip 127.0.0.0/8 |k Версия IP 127.0.0.0/8"
echo "Заблокировать IP k zzip 177.5.25.36 |k Заблокировать IP 177.5.25.36"
echo "избранное команды k fav | k любимые команды"
echo "Управление рынком приложений k app"
echo "Быстрое управление номерами заявок в приложении 26 | приложение k 1 панель | приложение k npm"
echo "управление Fail2ban в Fail2Ban | к f2b"
echo "Отображение информации о системе k info"
echo "Управление корневыми ключами k sshkey"
echo "Импорт открытого ключа SSH (URL) k sshkey <url>"
echo "Импорт открытого ключа SSH (GitHub) k sshkey github <пользователь>"

}



if [ "$#" -eq 0 ]; then
	# Без аргументов запустить интерактивную логику
	kejilion_sh
else
	# Если есть параметры, выполните соответствующую функцию
	case $1 in
		install|add|安装)
			shift
			send_stats "Установить программное обеспечение"
			install "$@"
			;;
		remove|del|uninstall|卸载)
			shift
			send_stats "Удаление программного обеспечения"
			remove "$@"
			;;
		update|更新)
			linux_update
			;;
		clean|清理)
			linux_clean
			;;
		dd|重装)
			dd_xitong
			;;
		bbr3|bbrv3)
			bbrv3
			;;
		nhyh|内核优化)
			Kernel_optimize
			;;
		trash|hsz|回收站)
			linux_trash
			;;
		backup|bf|备份)
			linux_backup
			;;
		ssh|远程连接)
			ssh_manager
			;;

		rsync|远程同步)
			rsync_manager
			;;

		rsync_run)
			shift
			send_stats "Запланированная синхронизация rsync"
			run_task "$@"
			;;

		disk|硬盘管理)
			disk_manager
			;;

		wp|wordpress)
			shift
			ldnmp_wp "$@"

			;;
		fd|rp|反代)
			shift
			ldnmp_Proxy "$@"
	  		find_container_by_host_port "$port"
	  		if [ -z "$docker_name" ]; then
	  		  close_port "$port"
			  echo "IP+порт заблокирован для доступа к сервису"
	  		else
			  ip_address
			  close_port "$port"
	  		  block_container_port "$docker_name" "$ipv4_address"
	  		fi
			;;

		loadbalance|负载均衡)
			ldnmp_Proxy_backend
			;;


		stream|L4负载均衡)
			ldnmp_Proxy_backend_stream
			;;

		swap)
			shift
			send_stats "Быстрая настройка виртуальной памяти"
			add_swap "$@"
			;;

		time|时区)
			shift
			send_stats "Быстро установить часовой пояс"
			set_timedate "$@"
			;;


		iptables_open)
			iptables_open
			;;

		frps)
			frps_panel
			;;

		frpc)
			frpc_panel
			;;


		打开端口|dkdk)
			shift
			open_port "$@"
			;;

		关闭端口|gbdk)
			shift
			close_port "$@"
			;;

		放行IP|fxip)
			shift
			allow_ip "$@"
			;;

		阻止IP|zzip)
			shift
			block_ip "$@"
			;;

		防火墙|fhq)
			iptables_panel
			;;

		命令收藏夹|fav)
			linux_fav
			;;

		status|状态)
			shift
			send_stats "Проверьте состояние программного обеспечения"
			status "$@"
			;;
		start|启动)
			shift
			send_stats "Запуск программного обеспечения"
			start "$@"
			;;
		stop|停止)
			shift
			send_stats "программная пауза"
			stop "$@"
			;;
		restart|重启)
			shift
			send_stats "Перезапуск программного обеспечения"
			restart "$@"
			;;

		enable|autostart|开机启动)
			shift
			send_stats "Программное обеспечение запускается автоматически при загрузке"
			enable "$@"
			;;

		ssl)
			shift
			if [ "$1" = "ps" ]; then
				send_stats "Посмотреть статус сертификата"
				ssl_ps
			elif [ -z "$1" ]; then
				add_ssl
				send_stats "Оформите сертификат быстро"
			elif [ -n "$1" ]; then
				add_ssl "$1"
				send_stats "Оформите сертификат быстро"
			else
				k_info
			fi
			;;

		docker)
			shift
			case $1 in
				install|安装)
					send_stats "Быстрая установка докера"
					install_docker
					;;
				ps|容器)
					send_stats "Быстрое управление контейнерами"
					docker_ps
					;;
				img|镜像)
					send_stats "Быстрое управление изображениями"
					docker_image
					;;
				*)
					linux_docker
					;;
			esac
			;;

		web)
		   shift
			if [ "$1" = "cache" ]; then
				web_cache
			elif [ "$1" = "sec" ]; then
				web_security
			elif [ "$1" = "opt" ]; then
				web_optimization
			elif [ -z "$1" ]; then
				ldnmp_web_status
			else
				k_info
			fi
			;;


		app)
			shift
			send_stats "Применить$@"
			linux_panel "$@"
			;;


		info)
			linux_info
			;;

		fail2ban|f2b)
			fail2ban_panel
			;;


		sshkey)

			shift
			case "$1" in
				"" )
					# sshkey → интерактивное меню
					send_stats "Интерактивное меню SSHKey"
					sshkey_panel
					;;
				github )
					shift
					send_stats "Импортировать открытый ключ SSH из GitHub."
					fetch_github_ssh_keys "$1"
					;;
				http://*|https://* )
					send_stats "Импортировать открытый ключ SSH из URL"
					fetch_remote_ssh_keys "$1"
					;;
				ssh-rsa*|ssh-ed25519*|ssh-ecdsa* )
					send_stats "Непосредственно импортируйте открытый ключ"
					import_sshkey "$1"
					;;
				* )
					echo "Ошибка: неизвестный параметр '$1'"
					echo "использование:"
					echo "k sshkey входит в интерактивное меню"
					echo "k sshkey \"<pubkey>\" Непосредственно импортировать открытый ключ SSH."
					echo "k sshkey <url> Импортировать открытый ключ SSH из URL-адреса."
					echo "k sshkey github <пользователь> Импортировать открытый ключ SSH из GitHub"
					;;
			esac

			;;
		*)
			k_info
			;;
	esac
fi
