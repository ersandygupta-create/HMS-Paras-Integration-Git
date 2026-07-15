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
        Jsontxt: Text;
        VJToken1: JsonToken;
        ITSMSEetup: Record "E3 ITSM Setup";
        webtext: Text;
    begin
        Clear(Content);
        Clear(ContentHeader);
        Clear(HttpClnt);
        Clear(Resp);

        if not ITSMSEetup.FindFirst() then
            Error('E3 ITSM Setup not found. Please setup E3 ITSM Setup details before sending asset details.');

        ITSMSEetup.TestField("Auth Token URL");
        webtext := ITSMSEetup."Auth Token URL";

        //ak
        if not HttpClnt.Get(webtext, Resp) then
            Error('Web Service Call failed');

        if not Resp.IsSuccessStatusCode then
            Error('The web service returned error message: Status Code : %1 Description : %2',
                Resp.HttpStatusCode, Resp.ReasonPhrase);

        Resp.Content.ReadAs(Jsontxt);
        VJToken1.ReadFrom(Jsontxt);

        GenerateToken(VJToken1, AssetDetails);
    end;

    local procedure GenerateToken(JToken: JsonToken; AssetDetails: Record "E3 Assets Details")
    var
        JObject: JsonObject;
        LKeys: List of [Text];
        VJToken2: JsonToken;
        JArray: JsonArray;
        i: Text;
        txttoken: Text;
    begin
        Clear(txttoken);

        if JToken.IsArray then begin
            JArray := JToken.AsArray();
            foreach VJToken2 in JArray do
                GenerateToken(VJToken2, AssetDetails);
        end else
            if JToken.IsObject then begin
                JObject := JToken.AsObject();
                Lkeys := JObject.Keys();

                foreach i in Lkeys do begin
                    JObject.Get(i, VJToken2);

                    if (i = 'token') then
                        txttoken := GetJsonToken(JObject, 'token').AsValue().AsText()
                    else
                        if VJToken2.IsObject or VJToken2.IsArray then
                            GenerateToken(VJToken2, AssetDetails);
                end;
            end;

        InsertAsset(txttoken, AssetDetails);
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure InsertAsset(txttoken: Text; AssetDetails: Record "E3 Assets Details")
    var
        JsonObj: JsonObject;
        CompanyInfo: Record "Company Information";
        Resps: HttpResponseMessage;
        HttpClnts: HttpClient;
        Contents: HttpContent;
        ContentHeaders: HttpHeaders;
        Jsontxts: Text;
        VJToken1s: JsonToken;
        ITSMSETUP: Record "E3 ITSM Setup";
        webtexts: Text;
        Jsonoutputs: Text;
    begin
        CompanyInfo.Get();

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
        JsonObj.Add('Departmentid', AssetDetails."Department Id");

        JsonObj.WriteTo(Jsonoutputs);

        Clear(Contents);
        Clear(ContentHeaders);
        Clear(HttpClnts);
        Clear(Resps);

        if not ITSMSETUP.FindFirst() then
            Error('E3 ITSM Setup not found. Please setup E3 ITSM Setup details before sending asset details.');

        ITSMSETUP.TestField("Asset Insert URL");
        webtexts := ITSMSETUP."Asset Insert URL";

        Contents.WriteFrom(Jsonoutputs);
        Contents.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpClnts.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + txttoken);

        //ak
        if not HttpClnts.Post(webtexts, Contents, Resps) then
            Error('Web Service Call failed');

        if not Resps.IsSuccessStatusCode then
            Error('The web service returned error message: Status Code : %1 Description : %2',
                Resps.HttpStatusCode, Resps.ReasonPhrase);

        Resps.Content.ReadAs(Jsontxts);
        VJToken1s.ReadFrom(Jsontxts);

        ReadResponse(VJToken1s, AssetDetails);
    end;

    local procedure ReadResponse(Response: JsonToken; AssetDetails: Record "E3 Assets Details")
    var
        JObject: JsonObject;
        LKeys: List of [Text];
        VJToken2: JsonToken;
        JArray: JsonArray;
        i: Text;
        StatusMsg: Text;
    begin
        Clear(StatusMsg);

        if Response.IsArray then begin
            JArray := Response.AsArray();
            foreach VJToken2 in JArray do
                ReadResponse(VJToken2, AssetDetails);
        end else
            if Response.IsObject then begin
                JObject := Response.AsObject();
                Lkeys := JObject.Keys();

                foreach i in Lkeys do begin
                    JObject.Get(i, VJToken2);

                    if (i = 'status') then
                        StatusMsg := GetJsonToken(JObject, 'status').AsValue().AsText()
                    else
                        if VJToken2.IsObject or VJToken2.IsArray then
                            ReadResponse(VJToken2, AssetDetails);
                end;

                AssetDetails.ITSMSend := true;
                AssetDetails.Status := StatusMsg;
                AssetDetails.Modify();
            end;
    end;
}