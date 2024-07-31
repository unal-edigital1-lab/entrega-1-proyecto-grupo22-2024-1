# Entrega 1 del proyecto WP01

* Alejandro Diaz Benavidez
* Yeison Dario Rojas Mora
* Daniel Santiago Navarro Gil
* Johan Hernan Lopez Alonso

### 1. Objetivo
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción a través de sensores y botones que permitan al usuario cuidar adecuadamente de ella.
#### 1.1 Objetivos especificos:
* Aplicar las tematicas del curso de electronica digital I para diseñar e implementar un sistema de Tamagotchi en FPGA
* 
*

### 2. Delimitaciones
El alcance del proyecto se centra en la creación de un sistema básico de Tamagotchi, que incluirá:
* Una interfaz de usuario operada mediante cinco botones físicos (rst, test y tres botones de accion).
* Tres sensores de interaccion: Sensor XXX de ultrasonido; sensor XXX de luz; Acelerometro/giroscopio XXX
* Un sistema de visualizacion compuesto por dos matrices LED 8x8 y un 7segg para representar el estado actual y las necesidades de la mascota virtual.
El proyecto se diseñará e implementará utilizando la FPGA ciclone IV, con restricciones claras en términos de recursos de hardware disponibles. La implementación se detallará en Verilog.

### 3. Especificaciones de diseño

El proyecto Tamagotchi en FPGA sera un sistema diseñado para emular el cuidado de una mascota virtual, permitiendo al usuario participar en actividades esenciales para su salud. El usuario tendra como objetivo mantener a su mascota en un estado optimo mediante un grupo acciones recurrentes: alimentar, jugar, dormir y asear. 
El sistema notificara al usuario del estado y las necesidades de la mascota a través de una interfaz visual y una alarma. Para que el usuario interactue, el sistema contara con cinco botones fisicos y tres sensores.

#### 3.1 Sistema de botones:
La interacción usuario-sistema se realizará mediante los siguientes botones configurados:
1. Reset:  Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
2. Test: Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación de los botones de interacción.
3. Botones de interaccion (3): Facilitan acciones directas como alimentar, jugar, o curar, posibilitando la implementación de actividades específicas para el bienestar del Tamagotchi. El boton de interaccion (1) permitira al usuario navegar por los distintos estados del tamagotchi en los cuales los botones (2) y (3) permitiran realizar acciones especificas asociadas a dicho estado y la visualización de los niveles actuales para cada estado.

#### 3.2 Sistema de sensado:
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporarán tres sensores que modifique el comportamiento de la mascota virtual en respuesta a estímulos externos:
* Sensor de sonido KY038: Utilizado para que el tamagotchi responda a estimulos sonoros, si la intensidad de ruido es baja o moderada el tamagochi aumentara su felicidad, mientras que una intensidad de ruido alta asustará al Tamagotchi y la reducirá.
* Sensor de luz: Utilizado para controlar el estado de descanso de la mascota, si la intensidad luminica es muy alta el usuario no se podrá enviar a descansar a la mascota. Si la intensidad luminica es muy baja por un tiempo determinado el Tamagotchi se dormirá y no permitirá interacciones.
*Sensor de movimiento Giroscopio MPU-6050: Utilizado para sensar patrones de movimiento repetitivos que simulen actividad fisica de la mascota, aumentando su nivel de felicidad y salud. De igual modo, movimientos muy bruscos asustarán al Tamagotchi y reducirán su nivel de felicidad.

#### 3.3 Sistema de visualizacion:
* Matriz de Puntos 16x16: 4 matrices 8x8 conectadas simultáneamente que simularán una matriz 16x16 para visualización más compleja. Representa visualmente el estado actual del Tamagotchi, incluyendo emociones y necesidades básicas.
* Display de 7 Segmentos: Utilizado para mostrar niveles y puntuaciones específicas, como el nivel de hambre o felicidad, complementando la visualización principal.
* Buzzer: Incorporado en la FPGA que emite sonidos dependiendo de los estados del Tamagotchi y avisando sobre eventos importantes o si el Tamagotchi se encuentra en un estado crítico.

## Componentes:
* 4 matrices 8x8
* Buzzer
* Display de 7 segmentos
* Sensor de sonido
* Sensor de luz
* Sensor de movimiento

### Descripcion funcional de componentes:

## Diagramas de caja negra:

## FSM:
