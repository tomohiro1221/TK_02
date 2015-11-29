int val;

int leftP   = 9;
int rightP  = 10;
int ledPin = 13;

void setup(){
  pinMode(leftP, OUTPUT);
  pinMode(rightP, OUTPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  digitalWrite(ledPin, LOW);
  if(Serial.available() > 0) {
    val = Serial.read();
    digitalWrite(ledPin, HIGH);
    digitalWrite(rightP, HIGH);
    digitalWrite(leftP, LOW);
    delay(val*1000);
  }else{
    digitalWrite(ledPin, LOW);
    digitalWrite(rightP, LOW);
    digitalWrite(leftP, LOW);
  }
}
