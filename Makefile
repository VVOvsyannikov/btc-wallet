# Перехват всех аргументов
%:
	@:

# Константы
DOCKER_CMD = docker compose run --rm app ruby btc_wallet.rb

# Установка проекта
build_image:
	docker compose build --no-cache

# установка зависимостей
install_gems:
	docker compose run --rm app bundle install

# Генерация ключа
generate:
	$(DOCKER_CMD) -g

# Проверка баланса кошелька
balance:
	$(DOCKER_CMD) -b -f $(from)

# Отправка биткоинов (make send amount=<amount> from=<from> to=<to>)
send:
	$(DOCKER_CMD) -s -a $(amount) -f $(from) -t $(to)

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

