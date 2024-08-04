# Entrega 1 del proyecto WP01

* Alejandro Diaz Benavidez
* Yeison Dario Rojas Mora
* Johan Hernan Lopez Alonso

## 1. Objetivo
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción a través de sensores y botones que permitan al usuario cuidar adecuadamente de ella.

### 1.1 Objetivos especificos:
* Aplicar las tematicas del curso de electronica digital I para diseñar e implementar un sistema de Tamagotchi en FPGA.
* Diseñar e mplementar la lógica de control del tamagotchi en verilog.
* Integrar y programar sensores y periféricos para la interacción del tamagotchi.

## 2. Delimitaciones
El alcance del proyecto se centra en la creación de un sistema básico de Tamagotchi, que incluirá:

* Una interfaz de usuario operada mediante cinco botones físicos (rst, test y tres botones de acción).
* Tres sensores de interaccion: Sensor de sonido KY038; sensor XXX de luz; Giroscopio MPU-6050.
* Un sistema de visualizacion compuesto por 4 matrices LED 8x8 y un 7segg para representar el estado actual y las necesidades de la mascota virtual.
El proyecto se diseñará e implementará utilizando la FPGA ciclone IV, con restricciones claras en términos de recursos de hardware disponibles. La implementación se detallará en Verilog.

## 3. Especificaciones de diseño

El proyecto Tamagotchi en FPGA sera un sistema diseñado para emular el cuidado de una mascota virtual, permitiendo al usuario participar en actividades esenciales para su salud. El usuario tendra como objetivo mantener a su mascota en un estado optimo mediante un grupo acciones recurrentes: alimentar, jugar, dormir y asear. 
El sistema notificara al usuario del estado y las necesidades de la mascota a través de una interfaz visual y una alarma. Para que el usuario interactue, el sistema contara con cinco botones fisicos y tres sensores.

### 3.1 Sistema de botones:
La interacción usuario-sistema se realizará mediante los siguientes botones configurados:
* __Reset:__  Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
* __Test:__ Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación de los botones de interacción.
* __Botones de interaccion (3):__ Facilitan acciones directas como alimentar, jugar, o curar, posibilitando la implementación de actividades específicas para el bienestar del Tamagotchi. El boton de interacción (1) permitira al usuario navegar por los distintos estados del tamagotchi en los cuales los botones (2) y (3) permitiran realizar acciones especificas asociadas a dicho estado y la visualización de los niveles actuales para cada estado.

### 3.2 Sistema de sensado:
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporarán tres sensores que modifique el comportamiento de la mascota virtual en respuesta a estímulos externos:

* __Sensor de sonido KY038:__ Utilizado para que el tamagotchi responda a estimulos sonoros, si la intensidad de ruido es baja o moderada el tamagochi aumentara su felicidad, mientras que una intensidad de ruido alta asustará al Tamagotchi y la reducirá.

* __Sensor de luz:__ Utilizado para controlar el estado de descanso de la mascota, si la intensidad luminica es muy alta el usuario no se podrá enviar a descansar a la mascota. Si la intensidad luminica es muy baja por un tiempo determinado el Tamagotchi se dormirá y no permitirá interacciones.

* __Sensor de movimiento Giroscopio MPU-6050:__ Utilizado para sensar patrones de movimiento repetitivos que simulen actividad fisica de la mascota, aumentando su nivel de felicidad y salud. De igual modo, movimientos muy bruscos asustarán al Tamagotchi y reducirán su nivel de felicidad.

### 3.3 Sistema de visualizacion:

* __Matriz de Puntos 16x16:__ 4 matrices 8x8 conectadas simultáneamente que simularán una matriz 16x16 para visualización más compleja. Representa visualmente el estado actual del Tamagotchi, incluyendo emociones y necesidades básicas.

* __Display de 7 Segmentos:__ Utilizado para mostrar niveles y puntuaciones específicas, como el nivel de hambre o felicidad, complementando la visualización principal.

* __Buzzer:__ Incorporado en la FPGA que emite sonidos dependiendo de los estados del Tamagotchi y avisando sobre eventos importantes o si el Tamagotchi se encuentra en un estado crítico.

## 4. Arquitectura del sistema:
### 4.1 Componentes:
* 4 matrices 8x8

* Buzzer

* Display de 7 segmentos

* Sensor de sonido KY038

* Sensor de luz 

* Sensor de movimiento MPU-6050

### 4.2 Descripcion funcional de componentes:
* __Matriz 8x8:__

* __Buzzer:__

* __Display de 7 segmentos:__

* __Sensor de sonido KY038:__ Es un módulo que permite detectar la presencia y la intensidad de sonidos en el entorno. Este módulo tiene dos salidas de información:
Analógica (A0): Lleva toda la información que está detectando el micrófono.
Digital(D0): Obtendremos una salida de encendido o apagado que se activa cuando el sonido supera un cierto volumen. Dicha salida de alta o baja se puede configurar mediante el ajuste del umbral.
  * __Componentes principales:__
    * __Microfono Electret__
    * __Potenciometro:__ Permite ajustar el umbral de sensibilidad para determinar el nivel de sonido necesario para activar la señal de salida.
    * __Comparador LM393:__ Se encarga de Comparar la señal del micrófono con el umbral ajustable, generando una señal digital de salida
    * __Indicadores LED:__ De alimentacion y señal digital de salida.
  * Entradas y salidas:
    * __VCC:__ Pin de alimentación (5V)
    * __GND:__ Pin de conexión a tierra.
    * ```DO (Digital Output)```: Pin de salida digital que se activa cuando el nivel de sonido supera el umbral ajustado.
    * ```AO (Analog Output)```: Pin de salida analógica que proporciona una señal proporcional a la intensidad del sonido detectado.

* __Modulo Sensor de luz con fotoresistor:__ Este modulo esta conformado por LDR o fotoresistor, el cual es sensible a la exposición de intensidad lumínica ambiental, para así determinar el brillo e intensidad lumínica del medio, este modulo a través de una salida digital, se puede programar un rango de luminosidad, proporcionando un nivel de tensión alto o bajo, dependiendo de la configuración preestablecida.
  * __Componentes principales:__
    * __Utiliza el comparador LM393 para mayor estabilidad__
    * __Potenciómetro__
    * __Leds de indicación__

* __Sensor de movimiento MPU-6050:__ Es un módulo avanzado que proporcionando una solución completa para la medición de la orientación y el movimiento. 
  * __Componentes principales:__
    * __Giroscopio de tres ejes__
    * __Acelerometro de tres ejes__
    * __Procesador de movimiento digital(DMP)__
    * El modulo cuenta con interfaz de comunicacion __I2C__.
  * Entradas y salidas:
    * __VCC:__ Pin de alimentación (3.3V - 5V)
    * __GND:__ Pin de conexión a tierra.
    * ```SCL (Serial Clock Line)```: Pin de reloj para la comunicación I2C.
    * ```SDA (Serial Data Line)```: Pin de datos para la comunicación I2C.
    * ```INT```: Pin de interrupción que puede ser configurado para notificar eventos específicos.
    
### 4.3 Interfaces de comunicacion:
* SPI
  
### 4.4 Diagramas de caja negra:


## 5 Especificaciones de diseño detalladas:
### 5.1 Modos de operacion:
#### 5.1.1 Modo Test
El modo Test permite a los usuarios y desarrolladores validar la funcionalidad del sistema y sus estados sin necesidad de seguir el flujo de operación normal. En este modo, se pueden forzar transiciones de estado específicas mediante pulsaciones del boton "Test", para verificar las respuestas del sistema y la visualización. Este modo es esencial durante la fase de desarrollo para pruebas rápidas y efectivas de nuevas características o para diagnóstico de problemas.

- **Activación:** Se ingresa al modo Test manteniendo pulsado el botón "Test" por un periodo de 5 segundos.

- **Funcionalidad:** Permite la navegación manual entre los estados del Tamagotchi, ignorando los temporizadores o eventos aleatorios, para observar directamente las respuestas y animaciones asociadas.

### 5.1.2 Modo Normal
El Modo Normal es el estado de operación estándar del Tamagotchi, donde la interacción y respuesta a las necesidades de la mascota virtual dependen enteramente de las acciones del usuario.

- **Activación:** El sistema arranca por defecto en el Modo Normal tras el encendido o reinicio del dispositivo. No requiere una secuencia de activación especial, ya que es el modo de funcionamiento predeterminado.

### 5.2 Estados y transiciones:
#### 5.2.1 Estados:
* Salud

* Hambre

* Descanso/sueño

* Felicidad

* Higiene

* Condicion Fisica

* Muerto
#### 5.2.1 Transiciones:
#### Sistema de niveles:
Cada estado del tamagotchi tendra asociado un nivel de satisfaccion en escala del 0 al 7. Los niveles aumentan o disminuyen segun las interacciones del usuario y el transcurso del tiempo de la siguiente forma:

<table>
  <tr>
    <th>Nivel</th>
    <th>Interacción</th>
    <th>Inactividad</th>
  </tr>
  <tr>
    <td>0</td>
    <td>+2</td>
    <td>-1 salud </td>
  </tr>
  <tr>
    <td>1-3</td>
    <td>+1</td>
    <td>-1</td>
  </tr>
    <tr>
    <td>4-6 </td>
    <td>+1</td>
    <td>-2 </td>
  </tr>
    <tr>
    <td>7</td>
    <td>-1 salud </td>
    <td>-2 - + 1 salud </td>
  </tr>
</table>

La salud es el unico estado que no dependera del paso del tiempo o la interaccion, en cambio su valor esta definido en funcion del nivel de los demas estados, un estado de 4-7 en cualquier atributo sumara un nivel a la salud al actualizarse positivamente, un estado del 1-3 no tendra efecto sobre la salud al actualizarse y un estado de 0 restara un nivel al ser detectado y por permanecer en dicho valor. Si el valor de la salud llega a 0 automaticamente hay una transicion al estado __Muerto__. Una vez en el estado __Muerto__ la unica interacion posible sera usar el boton __reset__ para reiniciar la mascota.

#### Temporizadores:
El temporizaron se encarga de generar cambios en los estados de la mascota simulando el paso del tiempo. El temporizaron contabilizara intervalos de 15 minutos para todos los estados del tamagotchi a excepcion del estado __Salud__ y el estado __Muerto__, pasado este tiempo ocurrira un cambio en el nivel del estado y el contador se reiniciara. En el modo test el valor del contador podra ser manipulado por el usuario para actualizar los estados rapidamente.

#### Interacciones:
Las interacciones del usuario pueden ser de dos tipos, cambio de estado y cuidado:
* Cambio de estado: El usuario presionara el boton (1) lo que le permitira navegar por los diferentes estados de la mascota, cada pulsacion mostrara el siguiente estado (en la secuencia hambre, sueño, felicidad, higiene, condicion), esta interaccion no afectara los niveles de estado ni los temporizadores.
* Cuidado: El ususario interactua ya sea con el boton (2) o con un sensor. Cada interaccion de cuidado afectara el nivel del estado activo de la mascota segun la tabla mostrada anteriormente.

### 5.3 FSM:
