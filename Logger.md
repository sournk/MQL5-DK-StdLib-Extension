# CDKLogger
Simplest Logger class for MetaTrader 5 is published on [mql5.com/en/code/52741](https://www.mql5.com/en/code/52741) as free library for MetaTrader 5.

Every programmer has their own logger. I wrote my own for MQL5, inspired by the Python logging module.

This class is simplest. No hierarchy, rotators or formatters. It's simple and convenient for any project.

## Installation
1. Copy CDKLogger.mqh to MQL\Include\DKStdLib\Logger folder.
2. Import CDKLogger class.
`#include <DKStdLib\Logger\CDKLogger.mqh`

## Usage
```
CDKLogger logger;

// STEP 1. Init Logger with "MyLoggerName" name and INFO level
logger.Init("MyLoggerName", INFO);

// You can change default logger format "%name%:[%level%] %message%" to your own
// Use any pattern combination 
logger.Format = "%YYYY%-%MM%-%DD% %hh%:%mm%-%ss% - %name%:[%level%] %message%"; 

// STEP 2. If you like to filter message only with substings,
//         fill the FilterInList 
// 2.1. Add a substings to FilterIntList
logger.FilterInList.Add("Including-Substring-#1");        
logger.FilterInList.Add("Including-Substring-#2");        

// 2.2. Split string by ";" separator to add all substrings to FilterInList in one line
logger.FilterInFromStringWithSep("Including-Substring-#3;Including-Substring-#4", ";");  

// STEP 3. If you like to filter OUT message with substrings, but leave all others,
//         fill the FilterOutList 
// 3.1. Add a substrings to FilterOutList
logger.FilterOutList.Add("Excluding-Substring-#1");        
logger.FilterOutList.Add("Excluding-Substring-#2");        

// 3.2. Split string by ";" separator to add all substrings to FilterOutList in one line
logger.FilterOutFromStringWithSep("Excluding-Substring-#3;Excluding-Substring-#4", ";");  // use Filter In put your filter str sep by ; here

// STEP 4. Logging
logger.Debug("Debug: Including-Substring-#1", false);                  // Debug with no Alert
logger.Info("Info: Including-Substring-#1", true);                     // Info with Alert dialog
logger.Warn("Warn: Including-Substring-#1"); 
logger.Error("Error: Including-Substring-#1: Excluding-Substring-#1"); // Skipped because of FilterOutList
logger.Critical("Critical: Including-Substring-#1");

logger.Assert(true, 
              "Log msg if true", INFO,   // if ok
              "Log msg if false", ERROR, // if fails
              true);                     // Show Alert as well
logger.Assert(true, 
              "Same msg for true & false", 
              INFO,   // Log level if ok
              ERROR,  // Log level if fails
              false); // No Alert   
```

The following messages will be output to the log as a result of execution:
![Logging result](img/UM001.%20CDKLogger.png)

## Open issues
I often use class this way:
```
logger.Debug(StringFormat("%s/%d: My message: PARAM1=%f",
                          __FUNCTION__, __LINE__,
                          my_param));
```                          
But here we have an issue. StringFormat function parse string every time, even if the logging level does not require the message to be output.
If you need to output debug messages a lot, you'll have to wrap the output in a condition:
```
if(DEBUG >= logger.Level)                          
  logger.Debug(StringFormat("%s/%d: My message: PARAM1=%f",
                            __FUNCTION__, __LINE__,
                            my_param));      
```                            
The best way to do this would be to use StringFormat lazily, **==but unfortunately MQL5 doesn't support passing a dynamic number of function parameters==** to the Debug, Info, Error, and so on functions.

If you have any ideas on how this could be done, I'd love to hear them [here](https://www.mql5.com/en/forum/474608).