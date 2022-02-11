// Data lines (bits 0 - 7)
// Start at bit 7 (pin 5), and end at bit 0 (pin 12)
const int UPORT7 = 5;

// Control lines
const int VCB2 = 3;

void setup() {
    Serial.begin(38400);

    // Data lines - default to input
    for (int b = 0; b < 8; b++) pinMode(UPORT7 + b, OUTPUT);

    // Control lines
    pinMode(VCB2, OUTPUT); // Transition to trigger interrupt
    digitalWrite(VCB2, HIGH);
}

void loop() {
    while (Serial.available()) 
    {
        int c = Serial.read();
        int v = 128;
        digitalWrite(VCB2, HIGH);
        for (int b = 0; b < 8; b++)
        {
            digitalWrite(UPORT7 + b, (c & v) ? HIGH : LOW);
            v /= 2;
        }
        digitalWrite(VCB2, LOW);
    }
}
