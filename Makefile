# Установка проекта
build_image:
	docker compose build --no-cache

# установка зависимостей
install_gems:
	docker compose run --rm app bundle install

DOCKER_CMD = docker compose run --rm app ruby btc_wallet.rb

# Генерация ключа
generate:
	$(DOCKER_CMD) generate

# Проверка баланса кошелька
balance:
	$(DOCKER_CMD) balance

# Отправка биткоинов (make send <amount> <to>)
send:
	$(DOCKER_CMD) send $(word 2,$(MAKECMDGOALS)) $(word 3,$(MAKECMDGOALS))

# Для дебага
bash:
	docker compose run --rm app bash

# Запуск RSpec
rspec:
	docker compose run --rm app bundle exec rspec

# Запуск Rubocop-линтера
rubocop:
	docker compose run --rm app bundle exec rubocop

# Запуск Rubocop-линтера с безопасной автокоррекцией
rubocop_ac:
	docker compose run --rm app bundle exec rubocop -a

# Перехват всех аргументов
%:
	@:

