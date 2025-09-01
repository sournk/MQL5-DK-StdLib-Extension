//+------------------------------------------------------------------+
//|                                          DKSimplestCSVWriter.mqh |
//|                                                  Denis Kislitsyn |
//|                               https://kislitsyn.me/personal/algo |
//+------------------------------------------------------------------+
#property copyright   "Denis Kislitsyn"
#property link        "https://kislitsyn.me/personal/algo"
#property version     "1.00"
#property description "Simplest CSV file writer"

#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Generic\HashMap.mqh>

//+------------------------------------------------------------------+
//| Simplest class for CSV file writing and appending data          |
//+------------------------------------------------------------------+
class CDKSimplestCSVWriter {
 private:
  CArrayObj          Rows;

  CHashMap           <string, uint> Columns;
 public:
  void              ~CDKSimplestCSVWriter(void);
  void               Clear();                                                                  // Clear all data

  uint               AddRow();                                                                 // Add empty row and return its number

  bool               SetValue(uint aRowNumber, string aColumnName, string aValue);             // Set value by column name
  bool               SetValue(uint aRowNumber, int aColumnIndex, string aValue);               // Set value by column index

  bool               SetLastRowValue(string aColumnName, string aValue);                       // Set value in last row by column name
  bool               SetLastRowValue(int aColumnIndex, string aValue);                         // Set value in last row by column index

  uint               RowCount();                                                               // Return numbers of data rows without header
  uint               ColumnCount();                                                            // Return numbers of columns

  string             GetColumn(uint aColumnIndex, string aErrorValue = "");                    // Get column name by index

  bool               WriteCSV(const string aFilename, const bool aWriteHeader = true, 
                              const string aSep = ";", const int aAdditionalFileFlags = 0);    // Write CSV to file
};

//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
void CDKSimplestCSVWriter::~CDKSimplestCSVWriter(void) {
  for(int i = 0; i < Rows.Total(); i++)   {
    CArrayString *Row = Rows.At(i);
    if(Row != NULL)
      delete Row;
  }
}

//+------------------------------------------------------------------+
//| Clear all data                                                   |
//+------------------------------------------------------------------+
void CDKSimplestCSVWriter::Clear() {
  for(int i = 0; i < Rows.Total(); i++)   {
    CArrayString *Row = Rows.At(i);
    if(Row != NULL)
      delete Row;
  }

  Rows.Clear();
  Columns.Clear();
}

//+------------------------------------------------------------------+
//| Add empty row and return its number                              |
//+------------------------------------------------------------------+
uint CDKSimplestCSVWriter::AddRow() {
  CArrayString* Row = new CArrayString;
  Rows.Add(Row);
  return Rows.Total() - 1;
}

//+------------------------------------------------------------------+
//| Set value by column name                                         |
//+------------------------------------------------------------------+
bool CDKSimplestCSVWriter::SetValue(uint aRowNumber, string aColumnName, string aValue)  {
  uint ColumnIndex;
  if(!Columns.TryGetValue(aColumnName, ColumnIndex)) {
    ColumnIndex = ColumnCount();
    Columns.Add(aColumnName, ColumnIndex);
  }

  return SetValue(aRowNumber, (int)ColumnIndex, aValue);
}

//+------------------------------------------------------------------+
//| Set value by column index                                        |
//+------------------------------------------------------------------+
bool CDKSimplestCSVWriter::SetValue(uint aRowNumber, int aColumnIndex, string aValue) {
  if(aRowNumber >= (uint)Rows.Total())
    return false;

  CArrayString *Row = Rows.At(aRowNumber);
  if(Row == NULL)
    return false;

  // Extend row if necessary
  while(Row.Total() <= aColumnIndex)
    Row.Add("");

  Row.Update(aColumnIndex, aValue);
  return true;
}

//+------------------------------------------------------------------+
//| Set value in last row by column name                             |
//+------------------------------------------------------------------+
bool CDKSimplestCSVWriter::SetLastRowValue(string aColumnName, string aValue) {
  if(Rows.Total() <= 0)
    return false;

  return SetValue(Rows.Total() - 1, aColumnName, aValue);
}

//+------------------------------------------------------------------+
//| Set value in last row by column index                            |
//+------------------------------------------------------------------+
bool CDKSimplestCSVWriter::SetLastRowValue(int aColumnIndex, string aValue) {
  if(Rows.Total() <= 0)
    return false;

  return SetValue(Rows.Total() - 1, aColumnIndex, aValue);
}

//+------------------------------------------------------------------+
//| Return number of columns                                         |
//+------------------------------------------------------------------+
uint CDKSimplestCSVWriter::ColumnCount() {
  return Columns.Count();
}

//+------------------------------------------------------------------+
//| Return column name by index                                      |
//+------------------------------------------------------------------+
string CDKSimplestCSVWriter::GetColumn(uint aColumnIndex, string aErrorValue = "") {
  string keys[];
  uint values[];
  Columns.CopyTo(keys, values);

  if(aColumnIndex < (uint)ArraySize(keys))
    return keys[aColumnIndex];
  return aErrorValue;
}

//+------------------------------------------------------------------+
//| Return number of data rows without header                        |
//+------------------------------------------------------------------+
uint CDKSimplestCSVWriter::RowCount() {
  return Rows.Total();
}

//+------------------------------------------------------------------+
//| Write CSV to file (overwrite existing)                          |
//+------------------------------------------------------------------+
bool CDKSimplestCSVWriter::WriteCSV(const string aFilename, const bool aWriteHeader = true, const string aSep = ";", const int aAdditionalFileFlags = 0) {
  int fileHandle = FileOpen(aFilename, FILE_WRITE|FILE_TXT|aAdditionalFileFlags);
  if(fileHandle == INVALID_HANDLE)
    return false;

  // Write header if exists
  if(aWriteHeader && ColumnCount() > 0) {
    string header = "";
    string keys[];
    uint vals[];
    Columns.CopyTo(keys, vals);
    for(int i=0;i<ArraySize(keys);i++) 
      header += keys[i] + aSep;

    FileWriteString(fileHandle, header + "\n");
  }

  // Write data rows
  for(int i=0; i<Rows.Total(); i++) {
    CArrayString *Row = Rows.At(i);
    if(Row == NULL)
      continue;

    string rowString = "";
    for(int j = 0; j < Row.Total(); j++) {
      if(j > 0)
        rowString += aSep;
      rowString += Row.At(j);
    }
    FileWriteString(fileHandle, rowString + "\n");
  }

  FileClose(fileHandle);
  return true;
}
