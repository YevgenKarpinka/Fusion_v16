page 50008 "APIV2 - Agent Services"
{
    PageType = API;
    Caption = 'agentServices', Locked = true;
    APIPublisher = 'tcomtech';
    APIGroup = 'app';
    APIVersion = 'v1.0';
    EntityName = 'agentService';
    EntitySetName = 'agentServices';
    SourceTable = "Shipping Agent Services";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(agentServicesId; SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'agentServicesId', Locked = true;
                }
                field(serviceCode; Code)
                {
                    ApplicationArea = All;
                    Caption = 'serviceCode', Locked = true;
                }
                field(agentCode; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'agentCode', Locked = true;
                }
                field(description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'description', Locked = true;
                }
                field(ssCarrierCode; "SS Carrier Code")
                {
                    ApplicationArea = All;
                    Caption = 'ssCarrierCode', Locked = true;
                }
                field(ssCode; "SS Code")
                {
                    ApplicationArea = All;
                    Caption = 'ssCode', Locked = true;
                }
            }
        }
    }
}