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

* Una interfaz de usuario operada mediante cuatro botones físicos (rst, test y dos botones de acción).
* Tres sensores de interaccion: Sensor de sonido KY038; sensor XXX de luz; Giroscopio MPU-6050.
* Un sistema de visualizacion compuesto por 4 matrices LED 8x8 y un 7segg para representar el estado actual y las necesidades de la mascota virtual.
El proyecto se diseñará e implementará utilizando la FPGA ciclone IV, con restricciones claras en términos de recursos de hardware disponibles. La implementación se detallará en Verilog.

## 3. Especificaciones de diseño

El proyecto Tamagotchi en FPGA sera un sistema diseñado para emular el cuidado de una mascota virtual, permitiendo al usuario participar en actividades esenciales para su salud. El usuario tendra como objetivo mantener a su mascota en un estado optimo mediante un grupo acciones recurrentes: alimentar, jugar, dormir y asear. 
El sistema notificara al usuario del estado y las necesidades de la mascota a través de una interfaz visual y una alarma. Para que el usuario interactue, el sistema contara con cuatro botones fisicos y tres sensores.

### 3.1 Sistema de botones:
La interacción usuario-sistema se realizará mediante los siguientes botones configurados:
* __Reset:__  Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
* __Test:__ Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación de los botones de interacción.
* __Botones de interaccion (2):__ Facilitan acciones directas como alimentar, jugar, descansar o bañar, posibilitando la implementación de actividades específicas para el bienestar del Tamagotchi. El boton de interacción (1) permitira al usuario navegar por los distintos estados del tamagotchi en los cuales el boton (2) permitirá realizar acciones especificas asociadas a dicho estado y la visualización de los niveles actuales para cada estado.

### 3.2 Sistema de sensado:
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporarán tres sensores que modifique el comportamiento de la mascota virtual en respuesta a estímulos externos:

* __Sensor de sonido KY038:__ Utilizado para que el tamagotchi responda a estimulos sonoros, si la intensidad de ruido es baja o moderada el tamagochi aumentara su felicidad, mientras que una intensidad de ruido alta asustará al Tamagotchi y la reducirá.

* __Sensor de luz:__ Utilizado para controlar el estado de descanso de la mascota, si la intensidad luminica es muy alta el usuario no se podrá enviar a descansar a la mascota. Si la intensidad luminica es muy baja por un tiempo determinado el Tamagotchi se dormirá y no permitirá interacciones.

* __Sensor de movimiento Giroscopio MPU-6050:__ Utilizado para sensar patrones de movimiento repetitivos que simulen actividad fisica de la mascota, aumentando su nivel de felicidad y salud. De igual modo, movimientos muy bruscos asustarán al Tamagotchi y reducirán su nivel de felicidad.

### 3.3 Sistema de visualizacion:

* __Pantalla nokia 5110__ Pequeña pantalla gráfica LCD montada sobre una PCB de 4.5cm x 4.5cm. Posee una resolución de 84 x 48 pí­xeles sobre la que se pueden dibujar gráficos o textos. Representa visualmente el estado actual del Tamagotchi, incluyendo emociones y necesidades básicas.

* __Display de 7 Segmentos:__ Utilizado para mostrar niveles y puntuaciones específicas, como el nivel de hambre o felicidad, complementando la visualización principal.

* __Buzzer:__ Incorporado en la FPGA que emite sonidos dependiendo de los estados del Tamagotchi y avisando sobre eventos importantes o si el Tamagotchi se encuentra en un estado crítico.

## 4. Arquitectura del sistema:
### 4.1 Componentes:
* Display nokia 5110

* Buzzer

* Display de 7 segmentos

* Sensor de sonido KY038

* Sensor de luz 

* Sensor de movimiento MPU-6050

### 4.2 Descripción funcional de componentes:
* __Display Nokia 5110:__ Pequeña pantalla gráfica LCD montada sobre una PCB de 4.5 cm x 4.5 cm. Posee una resolución de 84 x 48 píxeles sobre la que se pueden dibujar gráficos o textos.
  * __Componentes principales:__
    * __LCD:__ La pantalla gráfica que permite dibujar y mostrar imágenes o texto.
    * __Controlador PCD8544:__ Un chip que facilita la interfaz entre el microcontrolador y la pantalla, permitiendo el control de los píxeles.
    * __Resistores:__ Para asegurar que los niveles de voltaje sean adecuados para la pantalla.
  * __Entradas y salidas:__
    * __VCC:__ Pin de alimentación (generalmente 3.3V).
    * __GND:__ Pin de conexión a tierra.
    * __SCE (Chip Enable):__ Pin para habilitar la comunicación con el display.
    * __RST (Reset):__ Pin para reiniciar el display.
    * __D/C (Data/Command):__ Pin que determina si se envía un comando o datos al display.
    * __DIN (Data In):__ Pin para la transmisión de datos.
    * __CLK (Clock):__ Pin para la señal de reloj que sincroniza la transmisión de datos.
  * __Función:__ El display Nokia 5110 se utiliza para mostrar gráficos o texto en diversas aplicaciones, como juegos o sistemas de monitoreo, y en el caso del Tamagotchi, muestra información sobre el estado, emociones o acciones del personaje.
  * 
* __Buzzer:__
Un buzzer es un dispositivo de salida que emite un sonido cuando se le aplica una corriente eléctrica.

  * __Componentes principales:__
    * __Elemento piezoeléctrico:__ La parte del buzzer que produce sonido cuando se deforma eléctricamente.
    * __Carcasa:__ Protege el elemento piezoeléctrico y amplifica el sonido.
  *__Entradas y salidas:__
    * __VCC:__ Pin de alimentación (generalmente 5V).
    * __GND:__ Pin de conexión a tierra.
    * __Pin de señal:__ Pin que recibe la señal de control para activar el buzzer.
  * __Función:__ El buzzer se utiliza para alertar al usuario de eventos importantes, como cuando el Tamagotchi necesita atención.

* __Display de 7 segmentos:__
Un display de 7 segmentos es un dispositivo de salida que puede mostrar dígitos del 0 al 9 usando siete segmentos LED que se encienden en diferentes combinaciones.

  * __Componentes principales:__
    * __Segmentos LED:__ Siete LEDs organizados en forma de número 8.
    * __Controlador de Display:__ Opcional, facilita el control de los segmentos individuales.
  * __Entradas y salidas:__
    * __VCC:__ Pin de alimentación (generalmente 5V).
    * __GND:__ Pin de conexión a tierra.
    * __Segmentos A-G:__ Pines para controlar cada uno de los siete segmentos.
    * __DP:__ Pin opcional para el punto decimal.
  * __Función:__
El display de 7 segmentos se utiliza para mostrar información numérica relevante, como el nivel de hambre, la felicidad, o el tiempo del Tamagotchi.

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
  * Entradas y salidas:
    * __VCC:__ Pin de alimentación (3.3V)
    * __GND:__ Pin de conexión a tierra.
    * ```DO (Digital Output)```: Pin de salida digital que se activa cuando el nivel de luz supera el umbral ajustado.

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
En este proyecto se plantea usar 2 interfaces de comunicación, el I2C que se usa para comunicar los datos obtenidos de un giroscopio con la maquina de estados, asi mismo se usa el SPI el cual logra hacer la transmisión correcta de datos entre la maquina de estados y la pantalla nokia 5110, la cual muestra las caras de nuestro tamagotchi.

#### SPI (Serial Peripheral Interface)
- **Descripción:**
  - SPI es un protocolo de comunicación síncrona de alta velocidad utilizado principalmente para la comunicación entre microcontroladores y periféricos como sensores, tarjetas de memoria, y pantallas.
  
- **Características:**
  - **Full-Dúplex:** Permite la transmisión y recepción de datos simultáneamente.
  - **Cables:** Utiliza cuatro líneas de comunicación:
    - **MOSI (Master Out Slave In):** Línea de datos desde el maestro hacia el esclavo.
    - **MISO (Master In Slave Out):** Línea de datos desde el esclavo hacia el maestro.
    - **SCK (Serial Clock):** Reloj generado por el maestro para sincronizar la transmisión de datos.
    - **SS/CS (Slave Select/Chip Select):** Línea para seleccionar el esclavo activo.
  - **Velocidades:** Puede operar a velocidades de hasta varios MHz.
  - **Topología:** Un maestro y múltiples esclavos, seleccionados mediante la línea SS/CS.
  - **Sin direccionamiento:** No tiene un esquema de direccionamiento incorporado, lo que simplifica el hardware pero requiere una línea SS/CS por cada esclavo.

#### I2C (Inter-Integrated Circuit)
- **Descripción:**
  - I2C es un protocolo de comunicación síncrona que permite la comunicación entre múltiples dispositivos utilizando solo dos líneas de comunicación. Es muy utilizado para conectar microcontroladores con sensores y otros periféricos de baja velocidad.
  
- **Características:**
  - **Bidireccional:** Utiliza un bus de datos bidireccional compartido.
  - **Cables:** Utiliza dos líneas de comunicación:
    - **SDA (Serial Data Line):** Línea de datos bidireccional.
    - **SCL (Serial Clock Line):** Línea de reloj generada por el maestro para sincronizar la transmisión de datos.
  - **Velocidades:** Soporta varias velocidades de operación:
    - **Estándar:** 100 kHz.
    - **Rápido:** 400 kHz.
    - **Alta Velocidad:** 3.4 MHz.
  - **Multipunto:** Permite múltiples maestros y esclavos en el mismo bus.
  - **Direccionamiento:** Utiliza direcciones de 7 o 10 bits para identificar dispositivos esclavos.
  - **Protocolos de transferencia:** Soporta transferencias de datos simples y complejas, incluyendo lecturas y escrituras combinadas.

### 4.4 Diagramas de caja negra:
A continuaciion se muestra el diagrama de caja negra que se planteo al inicio del proyecto. Este era solo un prototipo de la maquina de estados principal.
[<img src="img/G22 Edigital1 - Caja Negra.png">](https://lucid.app/lucidchart/bbb5cb64-7045-4149-8ae4-b84de991304b/edit?invitationId=inv_c0b7014b-6840-4804-9726-d6e230216194&page=0_0##)

Seguidamente presentamos los diagramas de caja negra de cada uno de los modulos en los que se dividio el proyecto.


### 4.5 Diagrama de bloques:
En la siguiente imagen se presenta el diagrama de bloques inicial que se habia planteado el cual solo evidenciaba la maquina de estados principal, como se observa es bastante extenso. Asi mismo en los avances siguintes se intento realizar una mejor version y mas entendible.  
[<img src="img/G22 Edigital1 - Diagrama de bloques.png">](https://lucid.app/lucidchart/bbb5cb64-7045-4149-8ae4-b84de991304b/edit?invitationId=inv_c0b7014b-6840-4804-9726-d6e230216194&page=PHj0tElPAV7X#)

## Diagrama de bloques Modulo FSM principal

Este diagrama de flujo describe la lógica principal del código con las decisiones clave, incluyendo el manejo de estados (como SLEEP, FOOD, BATH, etc.), el temporizador de prueba (test_timer), y la transición entre modos.

[<img src="img/Diagrama FSM.png">](//www.plantuml.com/plantuml/png/xPR1Yjim48RlUehfPSco1BOjfR36PRU9omOsJMcsq5jGx0aHMDOYAL1ww1lrAVfYjHrvTnfPiIxDAJv5urypclaS-xyrbckxaoLhVp1sCwj4BdWfVdATi1kD1ct2n0P6xKz8KxY-1Bl52aRBFxyl6TGNtGHOPogKIVPtJ8dujAf35Y65zowwKQhmWcjkjrvGxep8lIZ-G9qBWzwDBVAo9qk-qnehMqUM3rdsfJi5pnlHjLjQ8L7JDHgxagh0mzYXiAr6erWQXD5dvQOpLuM2PkTUtmnp_QP_ajrzKZk5rxwCI9zxSytrYya6YkH3u0pqeWp7uyJJ_DjjNqLA9QeaPUdN7QvDqqouN0kkWSCqkvlsfpbuIC92-joy2nofAiI63KP9943pqs8n7OH9_abHB9t-ZFAaA3_UFTuFeYJlloYKJdzIb6UKys_BsMIG9VbinS4a6qv7yqmp-vvzdSoMsI1GuZYYcP8z_mNh6IjP-VR96R8KxXSFqzNZR9x1EEIbQBUIs3LtUNxmr_E2Y086CJ1jPvnpZH8hMzTzsHhCUNML7BHD1l3IX882spQ8uNpR6awuk80ErgizhTw1X8qb2u1lt8ftk05Z4qpMV2yZapNIOydS6pigczCUJzUzCY8pTl9ZITs0msmTOMFL4xkj5pjP_WK0)

## Diagrama de bloques Modulo FSM pet (Caras)

1. El sistema espera el comando de reinicio (reset) o el inicio (start).
2. Si start es alto, se inicializa la FSM_pet:
- En el estado INIT, se envían los comandos de configuración del LCD.
- Luego, pasa al estado WIPE para limpiar la pantalla.
- Posteriormente, según las entradas face e icon, se dibujan los gráficos correspondientes en la pantalla.
- Cada vez que se manda un comando o datos al LCD, se espera a que el módulo spi_master termine su tarea antes de continuar.

[<img src="img/Diagrama FSM pet.png">](//www.plantuml.com/plantuml/png/VPBDRjD04CVl-nHpjAKUoZMXebAJIf4AGhI2epLTZvk1_J0xuo1u9vw25yDU1rXZw26nvcF--lzcvreKamxU6MLr13l6fuGUeIMuTSF723O6U8-9yT6HRE3s_dNJaveyPypctVv-_m32ekHnQxY3Af6Grg172b39Z--r0G3OEDisIHHUNi7bTaw9TP_AsD8KlVXLFNAdJQAdikMHjR5n20kTKMQTHAjyeiNi85yN7ITaLoH4Os_82K4LujdrNdfAc23ppcqJOmxXQZIx0irZdVXfJM2ZPmhVS9uyAogs4Gvl3Wz5zYPw36FwxcO754uyjI18pur7KKfGjQZOSBW0wzjwQtwFVZco8wZE0WA9H34eoQiQMFuoLZALwdaLcUUF9mfjrfwtiGBuS7YxBm3ksFUC2NeCYixXHB9skKED0drCCsJwlyTSXZRtLnrQkW2sCTIBhMp_3ORmUQ0IR_nv3WHLFe4Hyx9-dhDymuu3EYxUC1zA3efZMPL2ovsP_w_7p-3TJm00)

## Diagrama de bloques Modulo SPI Master
1. El módulo espera a que la señal start sea alta.
2. Una vez que start es alto, el módulo comienza la transmisión SPI:
- Carga los datos en un registro de desplazamiento (shift_reg).
- Alterna el reloj (sclk) para enviar los bits uno por uno a través de MOSI.
- Cuando se han enviado todos los bits, levanta la señal avail para indicar que está listo para una nueva transmisión.

[<img src="img/Diagrama movement_detect">](//www.plantuml.com/plantuml/png/ZLFDYXD14BxFKvINPHSLPYyk94Rse88tGV4YOQXqzoIb_HEwUY8YFf8d7o4lvan3KetjcEIIgQz-lg-_xdhaX34DpZQ9aZNmcd0RqI5e0s_jy2M02Xu-OIJSMCCBu3rr3ZcPs3Ivjm40MBpXlOaO8KFBZ54Fjpc4rGhkuUO6K2Kwc2bixo3jZ1yBZh_kSdMUOfNk8YTuEJOi1SRSzpUw6VXxLNb0iXFO5g0o5U8q8DFMemw0e5MHuntrgOjcEpLfJDYHBrafTIeCFejyM3RdpBSTMGEtad-LZqbS7F8ynGMcQS2PxFF3MaXExYdxzSG5cWvTZog52C_XlhQld5xqhK22fuLL-MSiZufzk32Yj4vi6Ykct9Ffex2Xr9zhPc_xMaCk2nRAqluhQEiRbM1qkHRmxrVoGrI_MBJhP-28mq_flke8CZi_kZ0aAFsOqIBl-tzgPO7QkgfQgFaQMR0vEkCrzSq5L129ylf0DaQMxQE9ZZn2YkZP4TFnjuSFxzy9ToMezfTJs3V2-JZ-3Sx-0G00)


## Diagrama de bloques Modulo Movement detect:
El módulo `movement_detect` es responsable de detectar el movimiento basado en el registro `x_reg`, evaluando su magnitud y comparándola con un umbral.

1. **Inicialización**: Al comenzar, si `reset_n` está en bajo (reset activo), el diagrama establece `movement` a `1` y `rescan` a `0`, y luego detiene el flujo.
  
2. **Condición `internal_clk`**: Si `internal_clk` está activo, se evalúa la señal `completed`:
   - Si `completed` es `1`, el sistema:
     - Calcula la magnitud de `x_reg` utilizando la función `magnitude`.
     - Si la magnitud es mayor a 80 (`x_greater`), evalúa si el bit de signo de `x_reg[7]` es 0 para actualizar `movement`.
     - Establece `rescan` a `1`.
   - Si `completed` es `0`, simplemente se establece `rescan` a `0`.

Este flujo cubre el proceso completo de cómo se maneja la detección de movimiento y el reinicio de la exploración. 

[<img src="img/Diagrama SPI master.png">]


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

El estado de _descanso/sueño_ sera el estado inicial de la mascota. Pasado un perido de incatividad y dependiendo del nivel de luz, la mascota siempre regresara a el estado _dencanso/sueño_. Cuando la mascota acumula un tiempo de sueño de 15 minutos se considera como una interaccion y su nivel asociado se actualiza. 

La salud es el unico estado que no dependera del paso del tiempo o la interaccion, en cambio su valor esta definido en funcion del nivel de los demas estados, un estado de 4-7 en cualquier atributo sumara un nivel a la salud al actualizarse positivamente, un estado del 1-3 no tendra efecto sobre la salud al actualizarse y un estado de 0 restara un nivel al ser detectado y por permanecer en dicho valor. Si el valor de la salud llega a 0 automaticamente hay una transicion al estado __Muerto__. Una vez en el estado __Muerto__ la unica interacion posible sera usar el boton __reset__ para reiniciar la mascota.

#### Temporizadores:
El temporizardor se encarga de generar cambios en los estados de la mascota simulando el paso del tiempo. El temporizaron contabilizara intervalos de tiempo diferentes para todos los estados del tamagotchi a excepcion del estado __Salud__ y el estado __Muerto__, pasado este tiempo ocurrira un cambio en el nivel del estado y el contador se reiniciara. En el modo test el valor del contador podra ser manipulado por el usuario para actualizar los estados rapidamente.

#### Interacciones:
Las interacciones del usuario pueden ser de dos tipos, cambio de estado y cuidado:
* Cambio de estado: El usuario presionara el boton (1) lo que le permitira navegar por los diferentes estados de la mascota, cada pulsacion mostrara el siguiente estado (en la secuencia hambre, sueño, felicidad, higiene, condicion), esta interaccion no afectara los niveles de estado ni los temporizadores.
* Cuidado: El ususario interactua ya sea con el boton (2) o con un sensor. Cada interaccion de cuidado afectara el nivel del estado activo de la mascota segun la tabla mostrada anteriormente.

