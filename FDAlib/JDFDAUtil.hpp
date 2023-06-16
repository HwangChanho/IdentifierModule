//
//  test.hpp
//  dylibTest
//
//  Created by jiran_daniel on 2023/06/07.
//

#ifndef JDFDAUtilCpp_hpp
#define JDFDAUtilCpp_hpp

#include <string>

extern "C" {

/**
 @brief     TCC.db 에서 값 조회 (TCC: Transmission Control Character Mac용 App의 접근권한 관련 정보가 저장된 DataBase)
 @author    Daniel Hwang
 @param     [in] _bundleID    FDA에 등록된 client의 path 또는 번들 ID
 @date      2023.06.07
*/
void checkFDAStatusOfApp(const char * _bundleID);

};

#endif


