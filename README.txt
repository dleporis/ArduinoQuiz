Instructions for Arduino Quiz game prototype:

Required applications: Arduino, Processing

Setup:
1) Set up Arduino electrical circuit as shown in Circuit.jpg
2) Plug in Arduino into PC via USB cable
3) Open QuizArduino/QuizArduino.ino
4) Go to tools/Board and choose version of your Arduino board.
5) Compile the Arduino code and upload it to the board.
6) Open QuizProcessing/QuizProcessing.pde 
7) Turn on the sound and run the Processing code. If the Arduino board is not responding, check the port name in Arduino app (right_bottom) and compare it to the printed list of USB ports in Processing. Then change the index number in the following code to match the USB serial port. It is usually between 0 and 3.
String portName = Serial.list()[1]; 


Enjoy the game:
1) Choose the theme by one of 3 buttons.
2) Game has 3 rounds
3) Each round listen to the question, and choose the answer A, B or C by turning the potentiometer (time limit 10 seconds).
4) After that, your answer will be evaluated, and you will move to the next round.
Adding new questions:
1) Record the new question with 3 options, one of them correct. This can be done for example by using smartphone recorder app. Use .mp3 format
2) Rename the sound file to the following format: Question_THEME_number.mp3 Use number 1 higher than the highest number in the specific theme.

The THEME is represented as following:

HIST ..........is for History
BIO ...........is for Biology
GEO ...........is for Geography

filename example:  Question_BIO_10.mp3

3) Move the sound file into QuizProcessing/data folder.
4) Open Questions_user_input.csv in QuizProcessing/data folder (recommended app is Libre Office), and add the question details into the spreadsheet.
5) Add question number into “THEME_number“ column, question description into “THEME_question_text“ column, and correct answer representation  A, B or C into THEME_correct_answer.
6) Save the spreadsheet as .csv file and close it.
7) Run the Processing file and the new question will be included.
