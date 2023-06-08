//
//  test.hpp
//  dylibTest
//
//  Created by jiran_daniel on 2023/06/07.
//

#ifndef JDFDAUtil_hpp
#define JDFDAUtil_hpp

#include "JDFDAUtil.h"

#include <string>

#ifdef __cplusplus

extern "C" {

class YourObjectiveCPPClass;

class YourObjectiveCPPClassWrapper {
public:
    YourObjectiveCPPClassWrapper();
    ~YourObjectiveCPPClassWrapper();

    void checkStatusWithServiceCpp(const std::string& service, const std::string& identifierOrPath);
    int selectRowsForServiceWithServiceCpp(const std::string& service, const std::string& identifierOrPath);
    void showAlertCpp(const std::string& text, bool isHandle);

private:
    YourObjectiveCPPClass* objectiveCPPObject;
};

#endif

#endif


