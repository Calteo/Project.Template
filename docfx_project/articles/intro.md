# Introduction
This is an simple component to make inter-process communication easy and possible. 
If you have ever used WCF and other there is quite a lot of setup and configuration to make things work. 
Beside that hides the typlical syntax of the code that your are making an inter-process call. 
That is quite misleading if you look at the typical code.
```
    var result = service.Method(some args)
```  
* The `.` suggests that the call is quick and cheap - which it might be not.
* The `service` suggests that the service is always existing - which it might be not.
* The `result` is exspected as an synchronous result - which it definitly is not. 
* Your program is blocked while the other process is doing its work - which might be for quite some time.

Therefore this component is taking a different approach. 
Basically you are sending a message from one process in a fire-and-forget method. 

# Sender
Here is a simple example for sending a message to a receiver.
```  
    sender.Post("message name", some args);
```      
* The method name `Post` suggests that you do not get an immeadiate result and are sending things somewhere else for processing.
* The call might throw an exception if the message could not be send.
* The call is quite generic and can deal with any argument as long it is serializable on both the sender and the receiver.

Before using a sender you have to tell him where to send the messages to. So the full code looks more like this.
```  
    // set up a sender to conntect via tcp to a host at the given port
    var sender = new Sender("tcp://host:port");
    // assume the the host understands "message name" with parameter of type string, int, bool (in that order).
    sender.Post("message name", "arg1", 11, true);
```  
You can *keep* the `Sender` object and us it multiple times.

# Receiver
To process the incomming message you have to setup an `Receiver`. To make things more readable you have 
to dereive your receiver from `Receiver` and add the message handling code. Here's an example.
```  
    public class HelloReceiver : Receiver
    {
        [MessageHandler("hello")]
        private void Hello(string name)
        {
            // do your things here
        }
    }
```      
And to use this receicer you simply create one and tell him where to listen for messages. Ok - and tell him to start listening.
```  
    var receiver = new HelloReceiver();
    receiver.AddListener("tcp://host:port");
    receiver.Start();
```      
The approprate call from the sender would be:
```  
    var sender = new Sender("tcp://host:port");
    sender.Post("hello", "John Doe");
```      
Note the first parameter must be name of the message as given in the attribute `MessageHandler` on the receiver. 
The other parameters must match the siganture of the method in the receiver (in this case - `string`).

If you want it even more to behave like messaging you can use the UDP protocol by simply changing `tcp://host:port` to `udp://host:port`. 
Of course on both sides - sender and receiver.

This is all it takes to send data an exceute a method on a different process. 
But be aware of a few things that might be unexspected.
* If the message name does not exist on the receiver or the parameter do not match the method signature then the message is simply dropped. 
Well the receiver could raise an event, but maybe this is for next version.
* If you use UDP then you do not know if your message got to the receiver. 
That is part how the protocol works. If you use TCP then you get a connection error if the receiver is unreachable. 
So you know that the message went to the receiver. Again that is part of the protocol.

# Answering
Ok - there comes the time where you need an answer from the receiver. Here is how you do it.
Simply do it the other way around. You write a `Receiver` class in the client and set it up to listing. 
Then you pass this receiver as an argument to the `Post` Method. 
On the receiver you should have a parameter of type `Sender` in the message signature. Sounds more complicated that it is.

For the client:
```      
    class ClientReceiver : Receiver
    {
        [MessageHandler("answer")]
        private void Answer(string reply)
        {
            // Here we got the reply from the receiver
        }
    }
    
    var clientReceiver = new ClientReceiver();
    clientReceiver.AddListener("udp://COMPUTER1");
    clientReceiver.Start();
    
    var sender = new Sender("udp://COMPUTER2:50001");
    sender.Post("sayhello", "Frank Banks", clientReceiver);
    
    // Keep your programm running to get the answer
```      
And for the server:    
```      
    class ServerReceiver : Receiver
    {
        [MessageHandler("sayhello")]
        private void SayHelloToSomebody(string name, Sender replyTo)
        {
            replyTo.Post("answer", $"Hi {name}!");
        }
    }
    
    var serverReceiver = new ServerReceiver();
    ServerReceiver.AddListener("udp://COMPUTER2:50001");
    serverReceiver.Start();
    
    // Keep your programm running to process the messages
```  
Again there are some things to notice.
* The receiver does not need a fixed port. So this url take a free port and sends it to the server.
* The receiver *might* answer to the given sender.
* The receiver *might* take some time to answer.
* You can pass more the one reply receiver to the server. 
Maybe one to send progess messages and on to get the final result. Or may one in case of an error. 
That all depends on your design of the communication.

The point is that somehow this design forces you to think of these possibilites.
If your reply receiver is used for multiple replies then it might be better to include a *token* in the reply that was given when sending
the message to the server. Otherwise you wil not know what the reply is repling to. ;-)

# Threading
Since the design is by default **asynchron** the messages are always processed in an **arbitrary** thead. 
Which means you must take care to synchronize the processing of the message with whatever the server is doing at this point. 
Especially if you use Windows Forms you will always have to use `Control.Invoke` mechanism to access the form elements. 
Have a look in the code to find an example of a Windows Forms client and server.
