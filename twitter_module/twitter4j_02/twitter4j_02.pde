import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.internal.util.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

// import Serial
import processing.serial.*;

// set instance "myPort"
Serial myPort;

int on = 0;

Twitter twitter;
Query query = null;
QueryResult queryResult = null;
String queryWord = "#JPHACKS";       //検索ワード
String resultWord = " ";      //検索したツイートを格納するところ
PImage icon = null;           //その人のイメージ画像
String username = null;       //user name

PFont font = createFont("MS Gosic", 20);
int count=0;

String consumerKey = "vX57iN79Jemv6Ls4uAyMZmmWV";
String consumerSecret = "PEpr2UoCAnGQsxjrsW0PvN1kOhr9mCAOdLJSjzuefi84IDaZDy";
String accessToken = "576875423-2HWlT4iTY3XhylcWD0M2mLD0ar7Zi3L6n2HfIULP";
String accessSecret = "gcwKuSj5IfHxYO2Uo8NMyvbODwzc3RrAdIU5UmiRa3VVr";

void setup(){
  size(1000, 700);
  frameRate(30);
 
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(consumerKey);
  cb.setOAuthConsumerSecret(consumerSecret);
  cb.setOAuthAccessToken(accessToken);
  cb.setOAuthAccessTokenSecret(accessSecret);
 
  twitter = new TwitterFactory(cb.build()).getInstance();
  query = new Query(queryWord);
  query.count(1);
  
  //set up serial port
  myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);
  myPort.write(0);
}

void draw(){
  background(255);
  if(count%900 == 0){
    try{
      queryResult = twitter.search(query);
    }
    catch(TwitterException e){
      println(e.getStatusCode());
    }
    if(queryResult != null){
      for(Status status:queryResult.getTweets()){
        resultWord = status.getText();         //tweet
        println(resultWord.length());
        icon = loadImage(status.getUser().getOriginalProfileImageURL(), "png");    //image
        username = status.getUser().getScreenName();                               //nameをここで取得
      }
      myPort.write(resultWord.length());
    }
    count = 0;
  }
  textFont(font);
  fill(0);
  textSize(10);
  text(username, 0, 100);
  textSize(20);
  text(resultWord, 0, 150);
  image(icon, 0, 0, 50, 50);
 
  count++;
}
