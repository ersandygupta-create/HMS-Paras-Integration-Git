codeunit 50029 "E3 ITSM API Integration"
{
    trigger OnRun()
    begin

    end;

    procedure SendAssetDetails(AssetDetails: Record "E3 Assets Details")
    var
        Resp: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        Content: HttpContent;
        HttpClnt: HttpClient;
        ContentHeader: HttpHeaders;
        Jsonoutput: Text;
        webtext: Text;
        Jsontxt: Text;
        VJToken1: JsonToken;
        ITSMSEetup: Record "E3 ITSM Setup";
    begin
        Clear(Content);
        Clear(ContentHeader);
        Clear(HttpClnt);
        Clear(Resp);
        Clear(webtext);
        if not ITSMSEetup.FindFirst() then
            Error('E3 ITSM Setup not found. Please setup E3 ITSM Setup details before sending asset details.');
        ITSMSEetup.TestField("Auth Token URL");

        webtext := ITSMSEetup."Auth Token URL";

        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');
        // HttpClnt.DefaultRequestHeaders.add('x-api-key', RecEInvoiceSetup."API Key");
        // HttpClnt.DefaultRequestHeaders.add('x-api-secret', RecEInvoiceSetup."Client secret");
        // HttpClnt.DefaultRequestHeaders.add('business-tin', RecCompanyInformation."VAT Registration No.");
        HttpRequestMessage.Content := Content;
        HttpRequestMessage.SetRequestUri(webtext);
        HttpRequestMessage.Method := 'GET';
        HttpClnt.Send(HttpRequestMessage, Resp);

        if not HttpClnt.Get(webtext, Resp) then
            Error('Web Service Call failed');

        if not Resp.IsSuccessStatusCode Then
            Error('the web service returned error message: ' +
                    'Status Code : %1 ' + 'Description : %2 ',
                    Resp.HttpStatusCode, Resp.ReasonPhrase);

        Resp.Content.ReadAs(Jsontxt);
        VJToken1.ReadFrom(Jsontxt);
        GenerateToken(VJToken1, AssetDetails);
    end;

    Local procedure GenerateToken(JToken: JsonToken; AssetDetails: Record "E3 Assets Details")
    var
        JObject: JsonObject;
        LKeys: List of [Text];
        VJToken2: JsonToken;
        JArray: JsonArray;
        i: Text;
        txttoken: Text;
    begin
        Clear(txttoken);

        if (JToken.IsArray) then begin
            JArray := JToken.AsArray();
            foreach VJToken2 in JArray do begin
                GenerateToken(VJToken2, AssetDetails);
            end;
        end
        else
            if JToken.IsObject then begin
                JObject := JToken.AsObject();
                Lkeys := JObject.Keys();

                foreach i in Lkeys do begin
                    JObject.Get(i, VJToken2);
                    if (i = 'token') then begin
                        txttoken := GetJsonToken(JObject, 'token').AsValue().AsText();
                    end
                    else
                        if VJToken2.IsObject OR VJToken2.IsArray then begin
                            GenerateToken(VJToken2, AssetDetails);
                        end;
                end;
            end;
        // Message('Hi');
        InsertAsset(txttoken, AssetDetails);
    End;

    local procedure GetJsonToken(JsonObj: JsonObject; PropertyName: Text; var Token: JsonToken): Boolean
    begin
        exit(JsonObj.Get(PropertyName, Token));
    end;

    Local Procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            error('Could not find a token with key %1', Tokenkey);
    end;

    Local Procedure SetJsonToken(JsonObject: JsonObject; Path: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            error('Could not find a token with path %1', path);
    end;

    procedure InsertAsset(txttoken: Text; AssetDetails: Record "E3 Assets Details"): Text
    var
        JsonObj: JsonObject;
        CompanyInfo: Record "Company Information";
        Resps: HttpResponseMessage;
        HttpRequestMessages: HttpRequestMessage;
        Contents: HttpContent;
        HttpClnts: HttpClient;
        ContentHeaders: HttpHeaders;
        Jsonoutputs: Text;
        webtexts: Text;
        Jsontxts: Text;
        VJToken1s: JsonToken;
        ITSMSETUP: Record "E3 ITSM Setup";
    begin
        CompanyInfo.Get();

        //Root object
        JsonObj.Add('grn_no', AssetDetails."GRN No.");
        JsonObj.Add('grn_date', Format(AssetDetails."GRN Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('vendor_code', AssetDetails."Vendor No.");
        JsonObj.Add('vendor_name', AssetDetails."Vendor Name");
        JsonObj.Add('purchase_order_no', AssetDetails."PO No.");
        JsonObj.Add('item_no', AssetDetails."No.");
        JsonObj.Add('item_description', AssetDetails.Description);
        JsonObj.Add('location', AssetDetails."Location Code");
        JsonObj.Add('qty', AssetDetails.Quantity);
        JsonObj.Add('CompanyID', CompanyInfo.Name);
        JsonObj.Add('EntryNo', AssetDetails."Entry No.");
        JsonObj.Add('Departmentid', AssetDetails."Department Id"); //Department field is not present in E3 Asset details table'');
        JsonObj.WriteTo(Jsonoutputs);


        Clear(Contents);
        Clear(ContentHeaders);
        Clear(HttpClnts);
        Clear(Resps);
        Clear(webtexts);

        if not ITSMSETUP.FindFirst() then
            Error('E3 ITSM Setup not found. Please setup E3 ITSM Setup details before sending asset details.');
        ITSMSETUP.TestField("Asset Insert URL");
        webtexts := ITSMSETUP."Asset Insert URL";
        Message(Format(Jsonoutputs));
        Contents.WriteFrom(Jsonoutputs);
        Contents.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        HttpClnts.DefaultRequestHeaders.add('Authorization', 'Bearer ' + txttoken);
        HttpRequestMessages.Content := Contents;
        HttpRequestMessages.SetRequestUri(webtexts);
        HttpRequestMessages.Method := 'POST';
        HttpClnts.Send(HttpRequestMessages, Resps);

        if not HttpClnts.Post(webtexts, Contents, Resps) then
            Error('Web Service Call failed');

        Resps.Content.ReadAs(Jsontxts);
        VJToken1s.ReadFrom(Jsontxts);//s
        ReadResponse(VJToken1s, AssetDetails);//s
    end;

    Local procedure ReadResponse(Response: JsonToken; AssetDetails: Record "E3 Assets Details")
    var
        JObject: JsonObject;
        LKeys: List of [Text];
        VJToken2: JsonToken;
        JArray: JsonArray;
        i: Text;
        StatusMsg: Text;
    begin
        Clear(StatusMsg);

        if (Response.IsArray) then begin
            JArray := Response.AsArray();
            foreach VJToken2 in JArray do begin
                GenerateToken(VJToken2, AssetDetails);
            end;
        end
        else
            if Response.IsObject then begin
                JObject := Response.AsObject();
                Lkeys := JObject.Keys();

                foreach i in Lkeys do begin
                    JObject.Get(i, VJToken2);
                    if (i = 'status') then begin
                        StatusMsg := GetJsonToken(JObject, 'status').AsValue().AsText();
                    end
                    else
                        if VJToken2.IsObject OR VJToken2.IsArray then begin
                            GenerateToken(VJToken2, AssetDetails);
                        end;
                end;
                AssetDetails.ITSMSend := true;
                AssetDetails.Status := StatusMsg;
                AssetDetails.Modify();
            end;
    End;






}