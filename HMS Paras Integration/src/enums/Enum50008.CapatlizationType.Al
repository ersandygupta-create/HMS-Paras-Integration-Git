enum 50008 "E3 Capitalization Type"
{
    Extensible = true;

    value(0; None)
    {
        Caption = '';
    }
    value(1; One2Many)
    {
        Caption = 'One to Many';
    }
    value(2; Many2One)
    {
        Caption = 'Many to one';
    }
}