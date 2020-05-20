// EnergyWheel project for Structured system and Product development course, Aalborg University
// Energy Wheel quiz game - playing question, time counter, getting answer from Arduion determined by wheel speed, answer evaluation, measuring score, theme selection. 
// (c) Damián Leporis 22.04.2019
// -------------------------Libaries--------------------------------------------------------------------
//Add those to the Processing program "Sketch"->"Import Libary
import processing.serial.*;     // Serial connection. Default does not need to be installed
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*; //vector

//________________________________________________________________________________________________________________________
class QuizQuestion{
  protected int questionNumber;
  protected String correctAnswer;
  protected String theme;
  protected String questionText;
  public int reward;

  public QuizQuestion(int qu, String qText, String cA, int rw){
    questionNumber = qu;
    correctAnswer = cA;
    theme = "";
    questionText = qText;
    reward = rw;
  }
  
  int getQuestionNo(){
    return questionNumber;
  }
  String getTheme(){
    return theme;
  }
  String getCorrectAnrowswer(){
  return correctAnswer;
  }
  String getQuestionText(){
    return questionText;
  }
  int getReward(){
    return reward;
  }  
};
//________________________________________________________________________________________________________________________
//voláš super(questionNumber, questionText, correctAnswer, reward  );
//s parametrami questionNumber, questionText, correctAnswer, reward 
//ale do tej funkcie (konštruktora) ti vstupuje len questionNumber a reward - odkiaľ berieš tie ďalšie 4?
class GeographyQuestion extends QuizQuestion {
  GeographyQuestion(int questionNumber, String questionText, String correctAnswer, int reward ) {  
    super(questionNumber, questionText, correctAnswer, reward  );
    theme = "GEO";
  }
};
class BiologyQuestion extends QuizQuestion {
  BiologyQuestion(int questionNumber, String questionText, String correctAnswer, int reward ) {  
    super(questionNumber, questionText, correctAnswer, reward  );
    theme = "BIO";
  }
};

class HistoryQuestion extends QuizQuestion {
  HistoryQuestion(int questionNumber, String questionText, String correctAnswer, int reward ) {  
    super(questionNumber, questionText, correctAnswer, reward  );
    theme = "HIST";
  }
};

//________________________________________________________________________________________________________________________
class Quiz{
  protected QuizQuestion questions[];
  protected Boolean usedQuestions[];   
  protected int points;
  public int questionsDone;
  protected int questionsPerLevel;
  protected String theme;
  protected int reward;
  protected Table table;
  protected int rowCount;
  protected int max;
  
  Quiz(int qPL,int rw, String th){
    table = loadTable ("Questions_user_input.csv", "header");
    points = 0; // Vynulovať body
    rowCount = table.getRowCount();
    println("Table rowCount: " + rowCount);
    questionsDone = 0;
    questionsPerLevel = qPL; // Nastaviť žiadanú tému a počet otázok na level
    usedQuestions = new Boolean[rowCount];
    for (int i = 0; i <rowCount ; i++){
      usedQuestions[i] = false ;
    }
    theme = th;
    reward = rw;
    if (theme == "GEO"){
      questions = new GeographyQuestion[rowCount];
    }
    else if (theme == "BIO"){
      questions = new BiologyQuestion[rowCount];
    }
    else if (theme == "HIST"){
        questions = new HistoryQuestion[rowCount];
    }
  }
  void loadQuestionsFromTable(){  
    for (int i = 0; i<rowCount; i++){
      TableRow row = table.getRow(i);
      String column = String.format("%s_number", theme);
      int questionNumber = row.getInt(column);
      column = String.format("%s_question_text", theme);
      String questionText = row.getString(column);
      column = String.format("%s_correct_answer", theme);
      String correctAnswer = row.getString(column);
      if (correctAnswer.equals("") || correctAnswer.equals(" ")){
        println("no more questions");
        max = i;
        
        break;
      } else max = rowCount;
      if (theme == "GEO"){
        questions[i] = new GeographyQuestion(questionNumber, questionText, correctAnswer, reward);
      }
      if (theme == "BIO"){
        questions[i] = new BiologyQuestion(questionNumber, questionText, correctAnswer, reward);
      }
      if (theme == "HIST"){
        questions[i] = new HistoryQuestion(questionNumber, questionText, correctAnswer, reward);
       
      }
       println(theme + " question number " + questionNumber + " built");
    }  
    println("Maximal ammount of questions: " +max);
    println("______________________________ALL QUESTIONS BUILT______________________________________");
  }
  
  int getNextQuestion(){
    int randomNum = int(random(0, (max-1)));
    while (usedQuestions[randomNum] == true){
      randomNum = int(random(0, (max-1)));
    }
    println("Random: " + randomNum);
    println("Question number is: " + questions[randomNum].getQuestionNo());
    println("Question theme is: " + questions[randomNum].getTheme());
    println("Question text is: " + questions[randomNum].getQuestionText());
    println("Question answer is: " +questions[randomNum].getCorrectAnswer());
    String filename = String.format("Question_%s_%s.mp3",questions[randomNum].getTheme(), questions[randomNum].getQuestionNo());
    println(filename);
    playsound(filename);
    usedQuestions[randomNum] = true;
    return randomNum;
  }
  void addPoints(){
    points = points + reward;
  }
};
//------------------------ Global Constants & Variables ---------------------------------------

//Serial Communication
Serial myPort;  // Create object from Serial class
String serialdata;     // Data received from the serial port
boolean firstContact =false;  // if communication is established
Minim minim;   // Use Minim
AudioPlayer  player1;  // Create instance of mp3 player
Quiz quiz1;


//------------------------Functions------------------------------------------------
//plays sound file of a given name and waits until it stops playing
void playsound( String fileName){
       player1 = minim.loadFile(fileName);  
      //   player1.setGain(+1.0);  // Adjust volume if needed 
       player1.play();
       do{
       delay(500);
       }while (player1.isPlaying());
      }
      
String readSerialData(int dly){
  String  RawSerialdata = myPort.readStringUntil('\n');
  if (RawSerialdata != null) {  // if the data is not empty... 
    //trim whitespace and formatting characters (like carriage return)
    String serialdata = trim(RawSerialdata);
    return serialdata; 
  } else {
    println ("No serial available");
    delay(dly);
    return " ";
  }
}
 

//------------------------ Void Setup ---------------------------------------

void setup()
{
  minim = new Minim(this);  // loads audio player
  // Setup Serial Comm -----------------------------------------
  // List all the available serial ports. 
  printArray(Serial.list());

  // Open whatever port is the one you're using.
  String portName = Serial.list()[1]; //change the 4 to a 1 or 2 etc. to match the port your Ardruino is connected to
  myPort = new Serial(this, portName, 9600);   // Change the last number:  "... portName, XXX)  to the baud rate of serial connection.
  myPort.bufferUntil('\n');
  
  while(true){
    myPort.write('H');
    serialdata = readSerialData(200);
    if (serialdata.equals("K")){
      println("Connection confirmed OK");
      break;
    } else {
      println("Waiting for connection.");
      delay(200);
    }
  }
  playsound("Welcome.mp3");
  String theme ="";
  myPort.write('T'); //request theme from arduino
  while (theme ==""){
    // Read Serial
    serialdata = readSerialData(100);
    if (serialdata.equals("G")){
        theme = "GEO";
        playsound("StartGeography.mp3");
        break;
    }
    if (serialdata.equals("B")){
        theme = "BIO";
        playsound("StartBiology.mp3");
        break;
    }
    if (serialdata.equals("H")){
        theme = "HIST";
        playsound("StartHistory.mp3");
        break;
    } else {
        theme = "";
    }
  }
  println("chosen theme is: "+ theme); 
  quiz1 = new Quiz(3, 5, theme); //questions per level, reward per question
  quiz1.loadQuestionsFromTable();
  delay(500);
  myPort.write('I');
  playsound("Instructions.mp3");
  
}

//------------------------ Void  draw (== to void loop in Ard) ---------------------------------------
void draw() {
  
  if(quiz1.questionsDone >= quiz1.questionsPerLevel){
    println("you have completed the quiz");
    myPort.write('E');
    playsound("Thats_it.mp3");
    String Filename = String.format("Points_%s.mp3", quiz1.points);
    playsound(Filename);
    exit();
    return;
  }
  
  while(true){
    myPort.write('U'); // unlock monitor
    serialdata = readSerialData(100);
    if (serialdata.equals("segment monitor UNlocked")){
      println("OK UNLOCKED");
      break;
    } else {
      println("Waiting for monitor unlock.");
      delay(50);
    
    }
  }
  //getting a currentQuestion
  int questionNo = quiz1.getNextQuestion();
  player1 = minim.loadFile("Counter.mp3");
  player1.play();
  delay(18300);
  String answer = "";
  while (answer == ""){
    myPort.write('P');// request wheel speed from arduino 6 & lock monitor
    serialdata = readSerialData(10);
    println(serialdata);
    if (serialdata.equals("A") || serialdata.equals("B") || serialdata.equals("C")){
      switch (serialdata){
        case "A":{
          answer = "A";
          break;
        }
        case "B":{
          answer = "B";
          break;
        }
        case "C":{
          answer = "C";
          break;
        }
      }
    } else{
      answer = "";
    } 
  }
  println("Registered answer: "+ answer);
  delay(2000);
  String correctAns = quiz1.questions[questionNo].getCorrectAnswer();
  println("Correct answer is: "+correctAns);
  if (answer.equals(correctAns)){
    playsound("Correct.mp3");
    quiz1.addPoints();
  } else {
    switch(correctAns){
      case "A":{
        playsound("Incorrect_A.mp3");
        break;
      }
      case "B":{
        playsound("Incorrect_B.mp3");
        break;
      }
      case "C":{
        playsound("Incorrect_C.mp3");
        break;
      }
    } 
  }
  answer = "";
  serialdata = "";
  myPort.clear();
  quiz1.questionsDone = quiz1.questionsDone + 1;
  println("you have completed round " +  quiz1.questionsDone);
  println("_______________________________________________________________________________________________________");
  delay(2000);
  }
