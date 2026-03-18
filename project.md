# v_scr

План создания библиотеки на V (`v0.5.1+`), которая помогает писать код, близкий по духу к Bash, но остается типизированной библиотекой V, а не интерпретатором shell.

## Roles

Ты - профессионал senior в написании кода на Vlang, на golang, в bash ты профессионал и пишешь, активно используя башизмы.

## Идея

`v_scr` должен быть аналогом `go_scriptish` для V:

- переносить shell-like сценарии в обычный код V;
- давать компактный DSL для `pipeline` / `list` / условной логики;
- сохранять явную типизацию, явные ошибки и предсказуемое поведение;
- хорошо работать как в обычных `.v` проектах, так и в `.vsh` скриптах.

Ключевой принцип:

> `v_scr` похож на Bash по ergonomics, но остается библиотекой V с явной моделью исполнения.

## Что взять из go_scriptish

Сильная сторона `go_scriptish` не в наборе команд, а в модели:

- `Pipeline` и `List` как переиспользуемые последовательности шагов;
- категории шагов: `sources`, `filters`, `sinks`, `logic`, `builtins`;
- shell-подобные `stdout`, `stderr`, `exit code`;
- позиционные параметры и локальные переменные, использовать либо список аргументов к функции, но лучше - вариадические аргументы к функциям (произвольное их количество);
- возможность вызывать одну последовательность из другой;
- остановка исполнения при ошибке.

Это и есть основной каркас `v_scr`.

## Что не делать

На первом этапе `v_scr` не должен пытаться стать:

- полноценным Bash-парсером;
- эмулятором всех shell expansion rules;
- движком job control;
- стриминговым Unix pipe runtime с полной побайтной совместимостью.

Иначе библиотека быстро разрастется и потеряет простоту.

## Техническая база V

Для `v_scr` лучше не опираться на `os.execute()` как на основное API исполнения процессов.

Причина:

- `os.execute()` дает ограниченный результат;
- для полноценной работы нужны отдельные `stdout`, `stderr`, `stdin`;
- важны контроль процесса, `cwd`, `env`, редиректы и явное ожидание завершения.

Базовый runtime стоит строить на:

- `os.new_process()`
- `set_args(...)`
- `set_redirect_stdio()`
- `stdin_write(...)`
- `stdout_slurp()`
- `stderr_slurp()`
- `wait()`

## Цели API

API должен быть V-идиоматичным:

- snake_case вместо Go-style `CamelCase`;
- явные `Result`/`!` ошибки;
- компактные фабрики шагов;
- удобное чтение цепочек.

Пример желаемого стиля:

```v
import v_scr

count := v_scr.new_pipeline(
    v_scr.cat_file('/tmp/app.log'),
    v_scr.grep('error')!,
    v_scr.count_lines(),
).exec()!.parse_int()!
```

## Предлагаемая архитектура

### 1. Базовые типы

```v
pub type Step = fn (mut Pipe) !

pub struct Pipe {}
pub struct RunResult {}
pub struct Pipeline {}
pub struct List {}
```

### 2. Pipe

`Pipe` хранит состояние выполнения последовательности:

- `stdin []u8`
- `stdout []u8`
- `stderr []u8`
- `status int`
- `cwd string`
- `env map[string]string`
- `args []string`
- `locals map[string]string`
- `trace bool`

При необходимости позже можно добавить:

- флаги shell-совместимости;
- metadata по шагам;
- режимы memory/stream execution.

### 3. Семантика выполнения

`Pipeline`:

- `stdout` одного шага становится `stdin` следующего;
- ошибка или неуспешный статус останавливают исполнение по выбранной политике.

`List`:

- шаги исполняются последовательно;
- pipe-сцепка между шагами не обязательна;
- подходит для shell-like сценариев управления.

### 4. Capture API

Объект результата должен поддерживать:

- `bytes()`
- `string()`
- `trimmed_string()`
- `strings()`
- `parse_int()`
- `okay()`
- `status_code()`

## Публичное API первого приближения

### Конструкторы

- `new_pipeline(steps ...Step) Pipeline`
- `new_list(steps ...Step) List`
- `exec_pipeline(steps ...Step) !RunResult`
- `exec_list(steps ...Step) !RunResult`

### Источники

- `echo(input string) Step`
- `echo_args() Step`
- `cat_file(path string) Step`
- `cat_stdin() Step`
- `which(cmd string) Step`
- `list_files(path string) Step`
- `exec(cmd string, args ...string) Step`
- `sh(line string) Step`

### Фильтры

- `grep(pattern string) !Step`
- `grep_v(pattern string) !Step`
- `grep_r(pattern string) !Step` (для regexp-выражений, как в `grep -P`, можно grep_p, примени сразу хорошую библиотеку regexp из vlang stdlib)
- `sed(string) !Step` (аналог sed из linux, на первых порах можно вызывать sed через os.execute, пока не реализовывай сам sed )
- `head(n int) Step`
- `tail(n int) Step`
- `count_lines() Step`
- `count_words() Step`
- `sort() Step`
- `rsort() Step`
- `uniq() Step`
- `trim_whitespace() Step`
- `basename() Step`
- `dirname() Step`
- `strip_extension() Step`
- `swap_extensions(old_ext string, new_ext string) Step`

### Sinks

- `to_stdout() Step`
- `to_stderr() Step`
- `write_to_file(path string) Step`
- `append_to_file(path string) Step`
- `return_(status int) Step`
- `exit_(status int) Step`

### Builtins

- `mkdir(path string, mode u32) Step`
- `rm_file(path string) Step`
- `rm_dir(path string) Step`
- `touch(path string) Step`
- `chmod(path string, mode u32) Step`
- `test_filepath_exists(path string) Step`
- `test_empty() Step`
- `test_not_empty() Step`

### Логика

- `and_(sq SequenceLike) Step`
- `or_(sq SequenceLike) Step`
- `if_(expr Step, body SequenceLike) Step`
- `if_else(expr Step, body SequenceLike, else_body SequenceLike) Step`
- `run_pipeline(pl Pipeline) Step`
- `run_list(ls List) Step`

## Важное архитектурное решение

Нужны два уровня ошибок:

### 1. Ошибка V

Возникает, когда:

- не удалось открыть файл;
- невалидный regex;
- не удалось создать процесс;
- сломан сам runtime.

Это обычный `!` error.

### 2. Shell status

Возникает, когда:

- команда завершилась с кодом `!= 0`;
- тест не прошел;
- условие дало ложный shell-результат.

Это не обязательно V-error. Это часть `RunResult.status`.

Если смешать эти уровни, API станет неудобным и не похожим на shell-модель.

## Expansion model

Нужна упрощенная shell-like expansion модель:

- `$1 .. $9`
- `$*`
- `$#`
- `$VAR`
- `${VAR}`
- `${!VAR}`
- локальные переменные поверх `env`
- все переменные, работающие в bash-style, делай как map[string]string (потом мне самому будет нетрудно преобразовать в иной тип)

Порядок разрешения:

1. `locals`
2. `args`
3. `env`

Globbing стоит делать отдельной функцией или отдельным режимом, а не автоматически для каждой строки.

## Рекомендуемая структура репозитория

```text
v_scr/
├── v.mod
├── README.md
├── project.md
├── examples/
│   ├── basic_pipeline.v
│   ├── bash_to_vscr.v
│   └── deploy.vsh
├── v_scr/
│   ├── pipe.v
│   ├── result.v
│   ├── pipeline.v
│   ├── list.v
│   ├── step.v
│   ├── process.v
│   ├── expand.v
│   ├── sources.v
│   ├── filters.v
│   ├── sinks.v
│   ├── builtins.v
│   └── logic.v
└── tests/
    ├── pipeline_test.v
    ├── filters_test.v
    ├── process_test.v
    └── expansion_test.v
```

## План реализации

### Этап 1. Спека

Зафиксировать:

- scope `0.1.0`;
- модель `Pipeline` vs `List`;
- политику ошибок;
- минимальный публичный API;
- поведение expansion и tracing.

Результат:

- `project.md`
- черновой `README.md`
- список non-goals

### Этап 2. Ядро runtime

Сделать:

- `Step`
- `Pipe`
- `RunResult`
- `Pipeline`
- `List`
- `exec()` и capture methods

Результат:

- минимально исполнимая последовательность шагов без внешних процессов

### Этап 3. Process engine

Сделать:

- запуск внешних команд через `os.new_process()`;
- управление `cwd`;
- подстановка `env`;
- capture `stdout`, `stderr`, `exit code`;
- базовый tracing.

Результат:

- `exec(...)` и `sh(...)`

### Этап 4. Набор MVP-команд

Сделать минимум самых полезных операций:

- `echo`
- `cat_file`
- `grep`
- `head` / `tail`
- `count_lines`
- `count_words`
- `sort`
- `uniq`
- `trim_whitespace`
- `to_stdout`
- `to_stderr`
- `write_to_file`
- `append_to_file`
- `mkdir`
- `rm_file`
- `touch`
- `test_filepath_exists`

Результат:

- рабочая библиотека для типовых скриптов автоматизации

### Этап 5. Композиция и логика

Сделать:

- `run_pipeline`
- `run_list`
- `and_`
- `or_`
- `if_`
- `if_else`

Результат:

- возможность строить shell-like управляющие сценарии

### Этап 6. Expansion

Сделать:

- позиционные параметры;
- локальные переменные;
- env substitution;
- экранирование на минимально достаточном уровне.

Результат:

- API, пригодный для повторного использования сценариев

### Этап 7. Документация и примеры

Подготовить:

- README с примерами "bash -> v_scr";
- `.v` и `.vsh` примеры;
- cheatsheet соответствий.

Результат:

- низкий порог входа

### Этап 8. Тесты и релиз

Подготовить:

- unit tests для фильтров и expansion;
- integration tests для процессов и файловых операций;
- CI на Linux/macOS/Windows;
- публикацию в VPM.

## MVP 0.1.0

В первый релиз разумно включить только:

- core runtime;
- `Pipeline` и `List`;
- process engine;
- 12-15 базовых шагов;
- capture methods;
- env/args expansion;
- `and_` / `or_`.

Оставить на потом:

- полноценный shell parser;
- heredoc;
- асинхронные streaming pipelines;
- job control;
- полную bash-совместимость quoting/globbing.

## Основные риски

### 1. Избыточная эмуляция Bash

Если пытаться копировать Bash буквально, библиотека станет сложной и хрупкой.

### 2. Платформенные различия

Поведение команд, путей, quoting и shell invocation отличается между Unix и Windows.

### 3. Смешение V-errors и status codes

Это быстро сделает API неудобным и неочевидным.

### 4. Все в памяти

Если каждый шаг работает через `[]u8` буферы, очень большие потоки будут дорогими по памяти.

На `0.1.x` это приемлемо. Для `0.2+` можно думать о streaming-режиме.

## Рекомендуемый roadmap

Оценка без полировки, для одного разработчика:

- 2-3 дня: spec + каркас типов;
- 3-5 дней: process engine;
- 4-6 дней: MVP-команды;
- 2-3 дня: tests + examples + README;
- 1 день: packaging + VPM + release prep.

Итого:

- примерно 2-3 недели на качественный `0.1.0`.

## Следующие практические шаги

1. Создать каркас репозитория и `v.mod`.
2. Зафиксировать публичный API до написания реализации.
3. Реализовать ядро `Pipe` / `Pipeline` / `List`.
4. Поднять process engine через `os.new_process()`.
5. Собрать MVP-команды.
6. Написать примеры "из Bash в V".
7. Закрыть тестами критические сценарии.

## Источники

- `go_scriptish`: <https://pkg.go.dev/github.com/ganbarodigital/go_scriptish>
- V stdlib `os`: <https://modules.vlang.io/os.html>
- V docs, shell scripts / `.vsh`: <https://docs.vlang.io/other-v-features.html>
- V docs, modules: <https://docs.vlang.io/modules.html>
- V docs, package management: <https://docs.vlang.io/package-management.html>
