#include "MatrixKeypad.h"
#include <stdint.h>
#include <Keyboard.h>

// My keypad mapping is in 4x4 matrix
const byte rows = 4;
const byte cols = 4;

// The digitalPins where the rows & column pins are connected
byte rowPins[rows] = {2, 3, 4, 5};
byte colPins[cols] = {6, 7, 8, 9};

// Character mapping to keys
char key_chars[rows][cols] = {            // The symbols of the keys
  {'1', '2', '3', 's'},
  {'4', '5', '6', 'u'},
  {'7', '8', '9', 'p'},
  {'<', '0', '|', '>'}
};

boolean lockFewKeys = true;
int IndicesOfkeysToBeLocked[3] = {12, 14, 15};
char LockKeyChars[3] = {'<', '|', '>'};

// Notes:
// < means: execute DELETE key
// | means: execute RETURN key
// > means: execute ESC key
// ** we can't change them. These keys would be locked
// Rest character to key mapping is literal

// Create new New keypad called TerminalKeyBoard
MatrixKeypad_t *TerminalKeyBoard;


void setup() {
  //  Serial.begin(115200);
  //  Serial.println("Press any key on the keypad and it will show up here :");


  // Assigns char mapping to the keypad object
  TerminalKeyBoard = MatrixKeypad_create((char*)key_chars, rowPins, colPins, rows, cols);
  Keyboard.begin();

  //When the serial port opens, send the current key_map
  delay(1000);
  //  while (!Serial) {
  //  }
  //  Serial.println("Current keymap:");
  //  for (int r = 0; r < rows; r++) {
  //    for (int c = 0; c < cols; c++) {
  //      int idx = c + r * cols;
  //      Serial.print('[');
  //      Serial.print(idx);
  //      Serial.print(']');
  //      Serial.print('\t');
  //      Serial.println(key_chars[r][c]);
  //    }
  //  }
  //  Serial.println();
}




bool confBeingWritten = false;

void loop() {

  //  if (!confBeingWritten) {
  // Scans for a key press event
  MatrixKeypad_scan(TerminalKeyBoard);
  // If a key was pressed
  if (MatrixKeypad_hasKey(TerminalKeyBoard)) {
    char key = MatrixKeypad_getKey(TerminalKeyBoard);
    //    Serial.println(key);
    mapKeyEvents(key);
  }
  //  }

  //  Read serial data to get keymaps
  //  getKeyMapViaSerial(IndicesOfkeysToBeLocked, LockKeyChars);
}

char EnterKey = KEY_RETURN;
char BackspaceKey = KEY_BACKSPACE;
char ESCkey = KEY_ESC;
void mapKeyEvents(char _key) {
  switch (_key) {
    case '2':
      Keyboard.write('1');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '3':
      Keyboard.write('2');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '4':
      Keyboard.write('3');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '5':
      Keyboard.write('4');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '6':
      Keyboard.write('5');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '7':
      Keyboard.write('6');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '8':
      Keyboard.write('7');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '9':
      Keyboard.write('8');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '<':
      Keyboard.write('9');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '|':
      Keyboard.press(BackspaceKey);
      Keyboard.releaseAll();
      break;
    case '1':
      Keyboard.write('0');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '0':
      Keyboard.press(ESCkey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case '>':
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case 's':
      Keyboard.write('s');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case 'u':
      Keyboard.write('u');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
    case 'p':
      Keyboard.write('p');
      delay(100);
      Keyboard.press(EnterKey);
      Keyboard.releaseAll();
      delay(100);
      break;
  }
}
