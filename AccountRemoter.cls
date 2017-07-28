global with sharing class AccountRemoter {
    public String accountName { get; set; }
    public static Account account { get; set; }
    public static String HTMLResult { get; set; }
    public static List<Account> accounts { get; set; }
    public AccountRemoter() { } // empty constructor
    @RemoteAction
    global static List<Account> getAccount(String accountName) {
        accounts = [SELECT Id, Name, Phone, Type, NumberOfEmployees 
                   FROM Account WHERE Name = :accountName];
        return accounts;
    }
    @RemoteAction
    global static String getSharingBlowoutPage(String parentId) {
        String requestUrl = '/p/share/SharingBlowoutPage/d?parentId=' + parentId;
        Http httpConn1 = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + requestUrl);
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer ' + UserInfo.getSessionId());
        
        HTTPResponse res;
        if(!test.isrunningtest()){
          res = httpConn1.send(req);
       }
        else {
         res = new HttpResponse();
        }
        
        //If response is a re-direct to a different URL, issue a request to the re-direct URL provided back
        if ((res.getStatusCode() == 302) && (res.getHeader('Location') != null)) {
            Http httpConn2 = new Http();
            req.setHeader('Cookie', res.getHeader('Set-Cookie'));
            req.setHeader('Authorization','Bearer ' + UserInfo.getSessionId());
        }
        HTMLResult = req.toString() + req.getHeader('Cookie') + req.getHeader('Authorization') + res.toString() + res.getStatusCode() + res.getHeaderKeys() + res.getHeader('Location') + res.getBody() + '\r\n';
        HTMLResult = HTMLResult + 'null: ' + res.getHeader('null') + '\r\n';
        HTMLResult = HTMLResult + 'Date: ' + res.getHeader('Date') + '\r\n';
        HTMLResult = HTMLResult + 'Content-Length: ' + res.getHeader('Content-Length') + '\r\n';
        HTMLResult = HTMLResult + 'Expires: ' + res.getHeader('Expires') + '\r\n';
        HTMLResult = HTMLResult + 'Location: ' + res.getHeader('Location') + '\r\n';
        HTMLResult = HTMLResult + 'Set-Cookie: ' + res.getHeader('Set-Cookie') + '\r\n';
        HTMLResult = HTMLResult + 'Cache-Control: ' + res.getHeader('Cache-Control') + '\r\n';
        return HTMLResult;
    }
}