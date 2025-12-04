# Лабораторная работа №5 - Маршрутизация в IP сетях

## Полное пошаговое руководство для Cisco Packet Tracer

---

## 📋 Содержание
1. [Часть 1: Настройка инфраструктуры (AS100)](#часть-1-настройка-инфраструктуры-as100)
2. [Часть 2: Статическая маршрутизация](#часть-2-статическая-маршрутизация)
3. [Часть 3: Динамическая маршрутизация RIP (AS101)](#часть-3-динамическая-маршрутизация-rip-as101)
4. [Часть 4: Создание дополнительных сетей (AS102, AS103)](#часть-4-создание-дополнительных-сетей-as102-as103)
5. [Часть 5: Объединение сетей через BGP](#часть-5-объединение-сетей-через-bgp)

---

## Общая схема сетей

```
Сеть AS100 (192.168.0.0/24) - Статическая маршрутизация
Сеть AS101 (192.168.1.0/24) - RIP маршрутизация  
Сеть AS102 (192.168.2.0/24) - Одиночная сеть
Сеть AS103 (192.168.3.0/24) - Одиночная сеть
```

---

# Часть 1: Настройка инфраструктуры (AS100)

## Шаг 1.1: Размещение оборудования

**В Packet Tracer открой вкладку "Logical" (внизу слева)**

### Добавь роутеры:
1. Внизу найди панель устройств
2. Нажми **"Network Devices"** → **"Routers"** → **"PT-Router"**
3. Перетащи на рабочую область **4 штуки**
4. Расположи их примерно так:
```
        [Router1]
            |
        [Router2*] ← Это edge-роутер (пометь звездочкой)
            |
    [Switch 2960]
      /        \
[Router3]    [Router4]
```

### Добавь коммутатор:
1. **"Network Devices"** → **"Switches"** → **"2960-24TT"**
2. Перетащи **1 штуку** между Router3 и Router4

### Добавь компьютеры:
1. **"End Devices"** → **"End Devices"** → **"PC"**
2. Перетащи **3 штуки**:
   - PC0 рядом с Router1 (сеть №1)
   - PC1 рядом с Router3 (сеть №4)
   - PC2 рядом с Router4 (сеть №5)

---

## Шаг 1.2: Соединение устройств кабелями

**Используй кабели из панели снизу: "Connections" (иконка молнии)**

### Типы кабелей:
- **Copper Straight-Through** (прямой) - для соединений PC↔Switch, Switch↔Router
- **Copper Cross-Over** (перекрестный) - для соединений Router↔Router

### Соединения (запомни порты!):

| Откуда | Порт | Куда | Порт | Тип кабеля |
|--------|------|------|------|------------|
| PC0 | FastEthernet0 | Router1 | Fa0/0 | Straight |
| Router1 | Fa1/0 | Router2 | Fa0/0 | Cross-Over |
| Router2 | Fa1/0 | Switch | Fa0/1 | Straight |
| Switch | Fa0/2 | Router3 | Fa0/0 | Straight |
| Switch | Fa0/3 | Router4 | Fa0/0 | Straight |
| Router3 | Fa1/0 | PC1 | FastEthernet0 | Straight |
| Router4 | Fa1/0 | PC2 | FastEthernet0 | Straight |

---

## Шаг 1.3: Адресация сетей

### Разбиение 192.168.0.0/24 на подсети /28:

| Сеть | Диапазон адресов | Маска |
|------|------------------|-------|
| Сеть №1 (LAN1) | 192.168.0.0 - 192.168.0.15 | 255.255.255.240 |
| Сеть №2 | 192.168.0.16 - 192.168.0.31 | 255.255.255.240 |
| Сеть №3 | 192.168.0.32 - 192.168.0.47 | 255.255.255.240 |
| Сеть №4 (LAN4) | 192.168.0.48 - 192.168.0.63 | 255.255.255.240 |
| Сеть №5 (LAN5) | 192.168.0.64 - 192.168.0.79 | 255.255.255.240 |

### Распределение IP-адресов:

| Устройство | Интерфейс | IP-адрес | Маска | Сеть |
|------------|-----------|----------|-------|------|
| Router1 | Fa0/0 | 192.168.0.1 | 255.255.255.240 | №1 |
| Router1 | Fa1/0 | 192.168.0.17 | 255.255.255.240 | №2 |
| Router2* | Fa0/0 | 192.168.0.18 | 255.255.255.240 | №2 |
| Router2* | Fa1/0 | 192.168.0.33 | 255.255.255.240 | №3 |
| Router3 | Fa0/0 | 192.168.0.34 | 255.255.255.240 | №3 |
| Router3 | Fa1/0 | 192.168.0.49 | 255.255.255.240 | №4 |
| Router4 | Fa0/0 | 192.168.0.35 | 255.255.255.240 | №3 |
| Router4 | Fa1/0 | 192.168.0.65 | 255.255.255.240 | №5 |
| PC0 | Fa0 | 192.168.0.2 | 255.255.255.240 | №1 |
| PC1 | Fa0 | 192.168.0.50 | 255.255.255.240 | №4 |
| PC2 | Fa0 | 192.168.0.66 | 255.255.255.240 | №5 |

---

## Шаг 1.4: Настройка роутеров (CLI)

### Router1 - кликни на роутер → вкладка "CLI"

```
enable
configure terminal

hostname Router1

interface FastEthernet0/0
no shutdown
ip address 192.168.0.1 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.0.17 255.255.255.240
exit

exit
write memory
```

### Router2 (Edge-роутер, помечен *) - кликни на роутер → вкладка "CLI"

```
enable
configure terminal

hostname Router2

interface FastEthernet0/0
no shutdown
ip address 192.168.0.18 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.0.33 255.255.255.240
exit

exit
write memory
```

### Router3 - кликни на роутер → вкладка "CLI"

```
enable
configure terminal

hostname Router3

interface FastEthernet0/0
no shutdown
ip address 192.168.0.34 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.0.49 255.255.255.240
exit

exit
write memory
```

### Router4 - кликни на роутер → вкладка "CLI"

```
enable
configure terminal

hostname Router4

interface FastEthernet0/0
no shutdown
ip address 192.168.0.35 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.0.65 255.255.255.240
exit

exit
write memory
```

---

## Шаг 1.5: Настройка компьютеров (GUI)

### PC0:
1. Кликни на PC0
2. Вкладка **"Desktop"** → **"IP Configuration"**
3. Выбери **"Static"**
4. Заполни:
   - **IP Address:** `192.168.0.2`
   - **Subnet Mask:** `255.255.255.240`
   - **Default Gateway:** `192.168.0.1`

### PC1:
1. Кликни на PC1
2. Вкладка **"Desktop"** → **"IP Configuration"**
3. Заполни:
   - **IP Address:** `192.168.0.50`
   - **Subnet Mask:** `255.255.255.240`
   - **Default Gateway:** `192.168.0.49`

### PC2:
1. Кликни на PC2
2. Вкладка **"Desktop"** → **"IP Configuration"**
3. Заполни:
   - **IP Address:** `192.168.0.66`
   - **Subnet Mask:** `255.255.255.240`
   - **Default Gateway:** `192.168.0.65`

---

## Шаг 1.6: Проверка связи с соседями

На каждом PC открой **"Desktop"** → **"Command Prompt"** и пропингуй шлюз:

**PC0:**
```
ping 192.168.0.1
```

**PC1:**
```
ping 192.168.0.49
```

**PC2:**
```
ping 192.168.0.65
```

✅ Если пинги проходят (Reply from...) - всё ок!

---

# Часть 2: Статическая маршрутизация

## Шаг 2.1: Настройка статических маршрутов

### Router1 - CLI:

```
enable
configure terminal

ip route 192.168.0.32 255.255.255.240 192.168.0.18
ip route 192.168.0.48 255.255.255.240 192.168.0.18
ip route 192.168.0.64 255.255.255.240 192.168.0.18

exit
write memory
```

### Router2 (Edge*) - CLI:

```
enable
configure terminal

ip route 192.168.0.0 255.255.255.240 192.168.0.17
ip route 192.168.0.48 255.255.255.240 192.168.0.34
ip route 192.168.0.64 255.255.255.240 192.168.0.35

exit
write memory
```

### Router3 - CLI:

```
enable
configure terminal

ip route 192.168.0.0 255.255.255.240 192.168.0.33
ip route 192.168.0.16 255.255.255.240 192.168.0.33
ip route 192.168.0.64 255.255.255.240 192.168.0.35

exit
write memory
```

### Router4 - CLI:

```
enable
configure terminal

ip route 192.168.0.0 255.255.255.240 192.168.0.33
ip route 192.168.0.16 255.255.255.240 192.168.0.33
ip route 192.168.0.48 255.255.255.240 192.168.0.34

exit
write memory
```

---

## Шаг 2.2: Проверка маршрутизации

### Проверь пинги между всеми PC:

**С PC0:**
```
ping 192.168.0.50
ping 192.168.0.66
```

**С PC1:**
```
ping 192.168.0.2
ping 192.168.0.66
```

**С PC2:**
```
ping 192.168.0.2
ping 192.168.0.50
```

---

## Шаг 2.3: Сохрани таблицы маршрутизации (для отчета!)

### На каждом роутере выполни:

```
enable
show ip route
```

### Ожидаемый вывод Router1:
```
     192.168.0.0/28 is subnetted, 5 subnets
C       192.168.0.0 is directly connected, FastEthernet0/0
C       192.168.0.16 is directly connected, FastEthernet1/0
S       192.168.0.32 [1/0] via 192.168.0.18
S       192.168.0.48 [1/0] via 192.168.0.18
S       192.168.0.64 [1/0] via 192.168.0.18
```

### Ожидаемый вывод Router2:
```
     192.168.0.0/28 is subnetted, 5 subnets
S       192.168.0.0 [1/0] via 192.168.0.17
C       192.168.0.16 is directly connected, FastEthernet0/0
C       192.168.0.32 is directly connected, FastEthernet1/0
S       192.168.0.48 [1/0] via 192.168.0.34
S       192.168.0.64 [1/0] via 192.168.0.35
```

### Ожидаемый вывод Router3:
```
     192.168.0.0/28 is subnetted, 5 subnets
S       192.168.0.0 [1/0] via 192.168.0.33
S       192.168.0.16 [1/0] via 192.168.0.33
C       192.168.0.32 is directly connected, FastEthernet0/0
C       192.168.0.48 is directly connected, FastEthernet1/0
S       192.168.0.64 [1/0] via 192.168.0.35
```

### Ожидаемый вывод Router4:
```
     192.168.0.0/28 is subnetted, 5 subnets
S       192.168.0.0 [1/0] via 192.168.0.33
S       192.168.0.16 [1/0] via 192.168.0.33
C       192.168.0.32 is directly connected, FastEthernet0/0
S       192.168.0.48 [1/0] via 192.168.0.34
C       192.168.0.64 is directly connected, FastEthernet1/0
```

📸 **СДЕЛАЙ СКРИНШОТЫ для отчета!**

---

# Часть 3: Динамическая маршрутизация RIP (AS101)

## Шаг 3.1: Скопируй сеть AS100

1. Выдели всю сеть AS100 (роутеры, свитч, компьютеры)
2. **Ctrl+C** → **Ctrl+V**
3. Перемести копию в другое место на рабочей области
4. Переименуй роутеры в Router5, Router6, Router7, Router8 (для удобства)

---

## Шаг 3.2: Новая адресация для AS101

### Разбиение 192.168.1.0/24 на подсети /28:

| Сеть | Диапазон | Маска |
|------|----------|-------|
| Сеть №1 | 192.168.1.0 - 192.168.1.15 | 255.255.255.240 |
| Сеть №2 | 192.168.1.16 - 192.168.1.31 | 255.255.255.240 |
| Сеть №3 | 192.168.1.32 - 192.168.1.47 | 255.255.255.240 |
| Сеть №4 | 192.168.1.48 - 192.168.1.63 | 255.255.255.240 |
| Сеть №5 | 192.168.1.64 - 192.168.1.79 | 255.255.255.240 |

---

## Шаг 3.3: Настройка роутеров AS101 с RIP

### Router5 (аналог Router1) - CLI:

```
enable
configure terminal

hostname Router5

interface FastEthernet0/0
no shutdown
ip address 192.168.1.1 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.1.17 255.255.255.240
exit

router rip
version 2
no auto-summary
passive-interface FastEthernet0/0
network 192.168.1.0
exit

exit
write memory
```

### Router6 (Edge*, аналог Router2) - CLI:

```
enable
configure terminal

hostname Router6

interface FastEthernet0/0
no shutdown
ip address 192.168.1.18 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.1.33 255.255.255.240
exit

router rip
version 2
no auto-summary
network 192.168.1.0
exit

exit
write memory
```

### Router7 (аналог Router3) - CLI:

```
enable
configure terminal

hostname Router7

interface FastEthernet0/0
no shutdown
ip address 192.168.1.34 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.1.49 255.255.255.240
exit

router rip
version 2
no auto-summary
passive-interface FastEthernet1/0
network 192.168.1.0
exit

exit
write memory
```

### Router8 (аналог Router4) - CLI:

```
enable
configure terminal

hostname Router8

interface FastEthernet0/0
no shutdown
ip address 192.168.1.35 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.1.65 255.255.255.240
exit

router rip
version 2
no auto-summary
passive-interface FastEthernet1/0
network 192.168.1.0
exit

exit
write memory
```

---

## Шаг 3.4: Настройка компьютеров AS101 (GUI)

### PC3 (в сети №1):
- **IP Address:** `192.168.1.2`
- **Subnet Mask:** `255.255.255.240`
- **Default Gateway:** `192.168.1.1`

### PC4 (в сети №4):
- **IP Address:** `192.168.1.50`
- **Subnet Mask:** `255.255.255.240`
- **Default Gateway:** `192.168.1.49`

### PC5 (в сети №5):
- **IP Address:** `192.168.1.66`
- **Subnet Mask:** `255.255.255.240`
- **Default Gateway:** `192.168.1.65`

---

## Шаг 3.5: Включи отладку RIP

На каждом роутере AS101:
```
enable
debug ip rip
```

Подожди 30-60 секунд, чтобы RIP обменялся маршрутами.

Ты увидишь сообщения типа:
```
RIP: sending v2 update to 224.0.0.9 via FastEthernet1/0 (192.168.1.17)
RIP: received v2 update from 192.168.1.18 on FastEthernet1/0
```

---

## Шаг 3.6: Проверка и сохранение таблиц

### Проверь пинги:
```
ping 192.168.1.2
ping 192.168.1.50
ping 192.168.1.66
```

### Сохрани таблицы маршрутизации:

**Router5:**
```
enable
show ip route
```
Ожидаемый вывод:
```
     192.168.1.0/28 is subnetted, 5 subnets
C       192.168.1.0 is directly connected, FastEthernet0/0
C       192.168.1.16 is directly connected, FastEthernet1/0
R       192.168.1.32 [120/1] via 192.168.1.18, FastEthernet1/0
R       192.168.1.48 [120/2] via 192.168.1.18, FastEthernet1/0
R       192.168.1.64 [120/2] via 192.168.1.18, FastEthernet1/0
```

**Router6:**
```
     192.168.1.0/28 is subnetted, 5 subnets
R       192.168.1.0 [120/1] via 192.168.1.17, FastEthernet0/0
C       192.168.1.16 is directly connected, FastEthernet0/0
C       192.168.1.32 is directly connected, FastEthernet1/0
R       192.168.1.48 [120/1] via 192.168.1.34, FastEthernet1/0
R       192.168.1.64 [120/1] via 192.168.1.35, FastEthernet1/0
```

📸 **СДЕЛАЙ СКРИНШОТЫ для отчета!**

---

# Часть 4: Создание дополнительных сетей (AS102, AS103)

## Шаг 4.1: Создай AS102

### Добавь оборудование:
1. **1 роутер** (Router9) - "Network Devices" → "Routers" → "PT-Router"
2. **1 компьютер** (PC6) - "End Devices" → "PC"
3. Соедини их **прямым кабелем** (Fa0/0 роутера ↔ Fa0 компьютера)

### Настрой Router9 - CLI:

```
enable
configure terminal

hostname Router9

interface FastEthernet0/0
no shutdown
ip address 192.168.2.1 255.255.255.0
exit

exit
write memory
```

### Настрой PC6 (GUI):
- **IP Address:** `192.168.2.2`
- **Subnet Mask:** `255.255.255.0`
- **Default Gateway:** `192.168.2.1`

---

## Шаг 4.2: Создай AS103

### Добавь оборудование:
1. **1 роутер** (Router10) - "Network Devices" → "Routers" → "PT-Router"
2. **1 компьютер** (PC7) - "End Devices" → "PC"
3. Соедини их **прямым кабелем**

### Настрой Router10 - CLI:

```
enable
configure terminal

hostname Router10

interface FastEthernet0/0
no shutdown
ip address 192.168.3.1 255.255.255.0
exit

exit
write memory
```

### Настрой PC7 (GUI):
- **IP Address:** `192.168.3.2`
- **Subnet Mask:** `255.255.255.0`
- **Default Gateway:** `192.168.3.1`

---

# Часть 5: Объединение сетей через BGP

## Шаг 5.1: Схема соединения AS

```
     AS102 (192.168.2.0/24)
       |  \
       |   \
       |    \
     AS100   AS101 (192.168.1.0/24)
       |    /
       |   /
       |  /
     AS103 (192.168.3.0/24)
```

**Соединения между AS:**
- AS100 ↔ AS101 (10.0.1.0/30)
- AS100 ↔ AS102 (10.0.2.0/30)
- AS100 ↔ AS103 (10.0.3.0/30)
- AS101 ↔ AS102 (10.0.4.0/30)
- AS101 ↔ AS103 (10.0.5.0/30)

---

## Шаг 5.2: Добавь интерфейсы в роутеры

### ⚠️ ВАЖНО: Добавление модулей в роутеры

Для BGP нужны дополнительные порты. В Packet Tracer:

1. Кликни на роутер
2. Вкладка **"Physical"**
3. **ВЫКЛЮЧИ роутер** - нажми кнопку питания справа
4. Слева найди модули:
   - **PT-ROUTER-NM-1FFE** - FastEthernet порт
   - **PT-ROUTER-NM-1SS** - Serial порт
5. Перетащи нужные модули в свободные слоты
6. **ВКЛЮЧИ роутер** обратно

### Какие модули добавить:

| Роутер | Модули для добавления |
|--------|----------------------|
| Router2 (AS100) | 1x FastEthernet (Fa4/0), 2x Serial (Se2/0, Se3/0) |
| Router6 (AS101) | 1x FastEthernet (Fa4/0), 2x Serial (Se2/0, Se3/0) |
| Router9 (AS102) | 2x Serial (Se2/0, Se3/0) |
| Router10 (AS103) | 2x Serial (Se2/0, Se3/0) |

---

## Шаг 5.3: Соедини AS кабелями

### Используй Serial кабели для дальних соединений!

**"Connections" → "Serial DCE"** (для serial портов)
**"Connections" → "Copper Cross-Over"** (для FastEthernet между роутерами)

| Откуда | Порт | Куда | Порт | IP откуда | IP куда |
|--------|------|------|------|-----------|---------|
| Router2 (AS100) | Fa4/0 | Router6 (AS101) | Fa4/0 | 10.0.1.1/30 | 10.0.1.2/30 |
| Router2 (AS100) | Se2/0 | Router9 (AS102) | Se2/0 | 10.0.2.1/30 | 10.0.2.2/30 |
| Router2 (AS100) | Se3/0 | Router10 (AS103) | Se2/0 | 10.0.3.1/30 | 10.0.3.2/30 |
| Router6 (AS101) | Se2/0 | Router9 (AS102) | Se3/0 | 10.0.4.1/30 | 10.0.4.2/30 |
| Router6 (AS101) | Se3/0 | Router10 (AS103) | Se3/0 | 10.0.5.1/30 | 10.0.5.2/30 |

---

## Шаг 5.4: Настройка default gateway в AS100

### Router1 - добавь маршрут по умолчанию:

```
enable
configure terminal

ip route 0.0.0.0 0.0.0.0 192.168.0.18

exit
write memory
```

### Router3 - добавь маршрут по умолчанию:

```
enable
configure terminal

ip route 0.0.0.0 0.0.0.0 192.168.0.33

exit
write memory
```

### Router4 - добавь маршрут по умолчанию:

```
enable
configure terminal

ip route 0.0.0.0 0.0.0.0 192.168.0.33

exit
write memory
```

---

## Шаг 5.5: Настройка BGP на Router2 (Edge AS100)

```
enable
configure terminal

interface FastEthernet4/0
no shutdown
ip address 10.0.1.1 255.255.255.252
exit

interface Serial2/0
no shutdown
ip address 10.0.2.1 255.255.255.252
clock rate 64000
exit

interface Serial3/0
no shutdown
ip address 10.0.3.1 255.255.255.252
clock rate 64000
exit

ip route 192.168.0.0 255.255.255.0 Null0

router bgp 100
bgp router-id 1.1.1.1
bgp log-neighbor-changes
network 192.168.0.0 mask 255.255.255.0
neighbor 10.0.1.2 remote-as 101
neighbor 10.0.2.2 remote-as 102
neighbor 10.0.3.2 remote-as 103
exit

exit
write memory
```

---

## Шаг 5.6: Настройка BGP на Router6 (Edge AS101)

```
enable
configure terminal

interface FastEthernet4/0
no shutdown
ip address 10.0.1.2 255.255.255.252
exit

interface Serial2/0
no shutdown
ip address 10.0.4.1 255.255.255.252
clock rate 64000
exit

interface Serial3/0
no shutdown
ip address 10.0.5.1 255.255.255.252
clock rate 64000
exit

ip route 192.168.1.0 255.255.255.0 Null0

router bgp 101
bgp router-id 2.2.2.2
bgp log-neighbor-changes
network 192.168.1.0 mask 255.255.255.0
neighbor 10.0.1.1 remote-as 100
neighbor 10.0.4.2 remote-as 102
neighbor 10.0.5.2 remote-as 103
exit

router rip
default-information originate
exit

exit
write memory
```

---

## Шаг 5.7: Настройка BGP на Router9 (AS102)

```
enable
configure terminal

interface Serial2/0
no shutdown
ip address 10.0.2.2 255.255.255.252
exit

interface Serial3/0
no shutdown
ip address 10.0.4.2 255.255.255.252
exit

router bgp 102
bgp router-id 3.3.3.3
bgp log-neighbor-changes
network 192.168.2.0 mask 255.255.255.0
neighbor 10.0.2.1 remote-as 100
neighbor 10.0.4.1 remote-as 101
exit

exit
write memory
```

---

## Шаг 5.8: Настройка BGP на Router10 (AS103)

```
enable
configure terminal

interface Serial2/0
no shutdown
ip address 10.0.3.2 255.255.255.252
exit

interface Serial3/0
no shutdown
ip address 10.0.5.2 255.255.255.252
exit

router bgp 103
bgp router-id 4.4.4.4
bgp log-neighbor-changes
network 192.168.3.0 mask 255.255.255.0
neighbor 10.0.3.1 remote-as 100
neighbor 10.0.5.1 remote-as 101
exit

exit
write memory
```

---

## Шаг 5.9: Проверка BGP

### Подожди 1-2 минуты для установления BGP сессий!

### На Router2 (AS100) проверь соседей:

```
enable
show ip bgp summary
```

Ожидаемый вывод:
```
BGP router identifier 1.1.1.1, local AS number 100
...
Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
10.0.1.2        4   101     xxx     xxx       xx    0    0 xx:xx:xx        x
10.0.2.2        4   102     xxx     xxx       xx    0    0 xx:xx:xx        x
10.0.3.2        4   103     xxx     xxx       xx    0    0 xx:xx:xx        x
```

📸 **СДЕЛАЙ СКРИНШОТ для отчета!**

### Проверь таблицу маршрутизации:

```
show ip route
```

Должны появиться маршруты с буквой **B** (BGP):
```
B    192.168.1.0/24 [20/0] via 10.0.1.2
B    192.168.2.0/24 [20/0] via 10.0.2.2
B    192.168.3.0/24 [20/0] via 10.0.3.2
```

---

## Шаг 5.10: Трассировка маршрутов

### На каждом PC используй команду tracert:

**PC0 (AS100) → PC5 (AS101):**
```
tracert 192.168.1.66
```

**PC6 (AS102) → PC2 (AS100):**
```
tracert 192.168.0.66
```

**PC5 (AS101) → PC7 (AS103):**
```
tracert 192.168.3.2
```

**PC7 (AS103) → PC6 (AS102):**
```
tracert 192.168.2.2
```

📸 **СДЕЛАЙ СКРИНШОТЫ трассировок для отчета!**

---

## Шаг 5.11: Отключение линии AS100-AS102

1. Найди кабель между Router2 (AS100) и Router9 (AS102)
2. Кликни на него и удали (или просто отключи интерфейс)

### Или через CLI на Router2:

```
enable
configure terminal
interface Serial2/0
shutdown
exit
exit
```

### Подожди 1-2 минуты и повтори трассировку:

**PC6 (AS102) → PC2 (AS100):**
```
tracert 192.168.0.66
```

Теперь маршрут должен идти через AS101!

📸 **СДЕЛАЙ СКРИНШОТ для сравнения!**

---

## Шаг 5.12: Сохрани итоговые таблицы маршрутизации

### Router2 (AS100):
```
enable
show ip route
```

### Router6 (AS101):
```
enable
show ip route
```

### Router9 (AS102):
```
enable
show ip route
```

### Router10 (AS103):
```
enable
show ip route
```

📸 **СДЕЛАЙ СКРИНШОТЫ для отчета!**

---

# 📝 Артефакты для отчета

## 1. Команды настройки Router2 (со звездочкой) - Часть 2 (статика):

```
enable
configure terminal
hostname Router2

interface FastEthernet0/0
no shutdown
ip address 192.168.0.18 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.0.33 255.255.255.240
exit

ip route 192.168.0.0 255.255.255.240 192.168.0.17
ip route 192.168.0.48 255.255.255.240 192.168.0.34
ip route 192.168.0.64 255.255.255.240 192.168.0.35

exit
write memory
```

## 2. Команды настройки Router6 (со звездочкой) - Часть 3 (RIP):

```
enable
configure terminal
hostname Router6

interface FastEthernet0/0
no shutdown
ip address 192.168.1.18 255.255.255.240
exit

interface FastEthernet1/0
no shutdown
ip address 192.168.1.33 255.255.255.240
exit

router rip
version 2
no auto-summary
network 192.168.1.0
exit

exit
write memory
```

## 3. Команды BGP на Router2 (AS100) - Часть 5:

```
enable
configure terminal

interface FastEthernet4/0
no shutdown
ip address 10.0.1.1 255.255.255.252
exit

interface Serial2/0
no shutdown
ip address 10.0.2.1 255.255.255.252
clock rate 64000
exit

interface Serial3/0
no shutdown
ip address 10.0.3.1 255.255.255.252
clock rate 64000
exit

ip route 192.168.0.0 255.255.255.0 Null0

router bgp 100
bgp router-id 1.1.1.1
bgp log-neighbor-changes
network 192.168.0.0 mask 255.255.255.0
neighbor 10.0.1.2 remote-as 101
neighbor 10.0.2.2 remote-as 102
neighbor 10.0.3.2 remote-as 103
exit

exit
write memory
```

## 4. Команды BGP на Router6 (AS101) - Часть 5:

```
enable
configure terminal

interface FastEthernet4/0
no shutdown
ip address 10.0.1.2 255.255.255.252
exit

interface Serial2/0
no shutdown
ip address 10.0.4.1 255.255.255.252
clock rate 64000
exit

interface Serial3/0
no shutdown
ip address 10.0.5.1 255.255.255.252
clock rate 64000
exit

ip route 192.168.1.0 255.255.255.0 Null0

router bgp 101
bgp router-id 2.2.2.2
bgp log-neighbor-changes
network 192.168.1.0 mask 255.255.255.0
neighbor 10.0.1.1 remote-as 100
neighbor 10.0.4.2 remote-as 102
neighbor 10.0.5.2 remote-as 103
exit

router rip
default-information originate
exit

exit
write memory
```

## 5. Команда для просмотра BGP neighbors:

```
show ip bgp summary
show ip bgp neighbors
```

---

# ❓ Ответы на вопросы

## 1. Поясните результаты трассировки (п.8)

До отключения линии AS100-AS102 трафик между этими AS шел напрямую через Serial-соединение (10.0.2.0/30).

После отключения BGP автоматически пересчитал маршруты и нашел альтернативный путь через AS101. Теперь трафик идет: AS102 → AS101 → AS100.

Это демонстрирует главное преимущество BGP - автоматическую перестройку маршрутов при изменении топологии сети.

## 2. Как узнать об обновлениях BGP?

Несколько способов:

```
debug ip bgp updates
```
Показывает обновления BGP в реальном времени.

```
show ip bgp summary
```
Показывает состояние сессий и количество полученных префиксов.

```
show ip bgp
```
Показывает все известные BGP маршруты.

## 3. Различия между BGP и RIP

| Параметр | RIP | BGP |
|----------|-----|-----|
| Область применения | Внутренняя маршрутизация (IGP) | Внешняя маршрутизация (EGP) |
| Метрика | Количество хопов (max 15) | AS-PATH, атрибуты |
| Обновления | Периодические (30 сек) | По событиям |
| Настройка | Указываем сети | Указываем соседей и анонсируемые сети |
| Масштабируемость | Малые сети | Интернет-масштаб |
| Сложность | Простой | Сложный |

---

# 🎉 Готово!

Сохрани файл Packet Tracer и делай скриншоты для отчета!
