// EnergyWheel project for Structured system and Product development course, Aalborg University
// Arduino code for speed data measurement, theme selection, control of 7 segment monitor and sending data to Processing Quiz
// (c) Damián Leporis 22.04.2019

// ----------------------------Setup Global Variables------------------------------
// Variables placed before the void setup will be global)

// Serial Comms:
int serialdata; // Data received from the serial port
// answer recorded and sent
char wheel_answer;
// Pins and Buttons:
const int Btn1_pin = 6;
const int Btn2_pin = 7;
const int Btn3_pin = 8;
const int Potentiometer1_pin = 0;
const int LEDG_pin = 2;
const int LEDY_pin = 3;
const int LEDR_pin = 4;

//  initialize button states
int Btn1_state = 0;
int Btn2_state = 0;
int Btn3_state = 0;
int Potentiometer1_state = 0;


//----------------------End of "Setup Global Variables"---------------------------

void checkPotentiometer(){
      Potentiometer1_state = analogRead(Potentiometer1_pin);
      if (Potentiometer1_state <= 350) {
        wheel_answer = 'A';
        digitalWrite(LEDG_pin, HIGH);
        digitalWrite(LEDY_pin, LOW);
        digitalWrite(LEDR_pin, LOW);
      }
      else if (Potentiometer1_state > 350 && Potentiometer1_state <= 700) {
        wheel_answer = 'B';
        digitalWrite(LEDG_pin, LOW);
        digitalWrite(LEDY_pin, HIGH);
        digitalWrite(LEDR_pin, LOW);
      }
      else if (Potentiometer1_state > 700) {
        wheel_answer = 'C';
        digitalWrite(LEDG_pin, LOW);
        digitalWrite(LEDY_pin, LOW);
        digitalWrite(LEDR_pin, HIGH);
      }
  }

void ledWave(){
      digitalWrite(LEDG_pin, HIGH);
      delay (50);
      digitalWrite(LEDY_pin, HIGH);
      delay (50);
      digitalWrite(LEDG_pin, LOW);
      delay (50);
      digitalWrite(LEDR_pin, HIGH);
      delay (50);
      digitalWrite(LEDY_pin, LOW);
      delay (50);
      digitalWrite(LEDR_pin, LOW);
    }

// ---------------------------Void setup -----------------------------------------


void setup() {
  //( put your setup code here, to run once at startup:)

  Serial.begin(9600); // create serial object

  // Set up that the button and potentiometer pins have to be monitored as inputs 
  pinMode(Btn1_pin, INPUT);
  pinMode(Btn2_pin, INPUT);
  pinMode(Btn3_pin, INPUT);
  pinMode(Potentiometer1_pin, INPUT);
  
  // Setup output led pins
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(LEDG_pin, OUTPUT);
  pinMode(LEDY_pin, OUTPUT);
  pinMode(LEDR_pin, OUTPUT);

  ledWave();

}

void loop() {
  // (put your main code here, to run repeatedly:)
  int serialdata = Serial.read();
  if (serialdata == -1) {
    delay(50);
    return;
  }

  switch (serialdata) {
    case 'H':
      Serial.println("K");
      break;
    case 'P':
      checkPotentiometer(); 
      // send answer
      Serial.println(String(wheel_answer));
      // lock Leds
      Serial.println("segment monitor locked");
      break;
      
    case 'U':
      // unlock monitor
      Serial.println("segment monitor UNlocked");
      while (serialdata != 'P'){
        checkPotentiometer();
        serialdata = Serial.read();
        delay(2);
      }
      // lock Leds
      Serial.println("segment monitor locked");
      Serial.println("Recording answer");
      checkPotentiometer();
      //send answer
      Serial.println(String(wheel_answer));
      break;
    case 'T':
      Serial.println("checking theme");
      // chose theme
      char theme;
      Btn1_state = 0; 
      Btn2_state = 0;
      Btn3_state = 0;
      while (true) {
        Btn1_state = digitalRead(Btn1_pin);
        Btn2_state = digitalRead(Btn2_pin);
        Btn3_state = digitalRead(Btn3_pin);
        Serial.println(  "   Button1:"+ String(Btn1_state)+"   Button2:"+ String(Btn2_state)+"   Button3:"+ String(Btn3_state));
        if (Btn1_state == 1 && Btn2_state != 1 && Btn3_state != 1) {
          theme = 'G'; //geography
          break;
        }
        else if (Btn2_state == 1 && Btn1_state != 1 && Btn3_state != 1) {
          theme = 'B'; //biology
          break;
        }
        else if (Btn3_state == 1 && Btn1_state != 1 && Btn2_state != 1) {
          theme = 'H'; //history
          break;
        }
      }
      //LED WAVE
    
      Serial.println(String(theme));
      break;
    case 'I':
      delay(3000);
      digitalWrite(LEDG_pin, HIGH);
      delay (3000);
      digitalWrite(LEDG_pin, LOW);
      delay (100);
      digitalWrite(LEDY_pin, HIGH);
      delay (3000);
      digitalWrite(LEDY_pin, LOW);
      delay (100);
      digitalWrite(LEDR_pin, HIGH);
      delay (3000);
      digitalWrite(LEDR_pin, LOW);
      break;
        
    case 'E':
      for (int i = 0; i < 23; i++){
        ledWave();
        digitalWrite(LEDR_pin, HIGH);
        delay (50);
        digitalWrite(LEDY_pin, HIGH);
        delay (50);
        digitalWrite(LEDR_pin, LOW);
        delay (50);
        digitalWrite(LEDG_pin, HIGH);
        delay (50);
        digitalWrite(LEDY_pin, LOW);
        delay (50);
        digitalWrite(LEDG_pin, LOW);
        delay (50);
      } 
      break;
  }
}
