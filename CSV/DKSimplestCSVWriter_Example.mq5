//+------------------------------------------------------------------+
//|                                Example_CDKSimplestCSVWriter.mq5  |
//|                                                 Denis Kislitsyn  |
//|                              https://kislitsyn.me/personal/algo  |
//+------------------------------------------------------------------+
#property copyright   "Denis Kislitsyn"
#property link        "https://kislitsyn.me/personal/algo"
#property version     "1.00"
#property description "Simplest CSV file writer example"

#include <DKSimplestCSVWriter.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
  string Filename = "filename_writer.csv";

  CDKSimplestCSVWriter CSVFile; // Create class object

  // Add first row and set values by column name
  CSVFile.AddRow();
  CSVFile.SetLastRowValue("Time", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
  CSVFile.SetLastRowValue("Open", DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_BID), _Digits));
  CSVFile.SetLastRowValue("Close", DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_ASK), _Digits));

  // Add second row using returned row index and SetValue by name
  uint r = CSVFile.AddRow();
  CSVFile.SetValue(r, "Time", TimeToString(TimeCurrent() + 60, TIME_DATE|TIME_MINUTES));
  CSVFile.SetValue(r, "Open", DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_BID), _Digits));
  CSVFile.SetValue(r, "Close", DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_ASK), _Digits));

  // Demonstrate SetValue by column index (index 0..n-1). Here we set first column of first row to a custom value
  if (CSVFile.RowCount() > 0 && CSVFile.ColumnCount() > 0)
    CSVFile.SetValue(0, 0, "CUSTOM_TIME");

  // Write CSV to file. Pass FILE_ANSI to write ANSI encoded file if desired.
  if (CSVFile.WriteCSV(Filename, true, ";", FILE_ANSI)) {
    PrintFormat("Successfully wrote %d rows with %d columns to: %s", 
                CSVFile.RowCount(), CSVFile.ColumnCount(), Filename);
  } else {
    PrintFormat("Error writing CSV file: %s", Filename);
  }

  // Optional: clear memory
  CSVFile.Clear();
}
//+------------------------------------------------------------------+
