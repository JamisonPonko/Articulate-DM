USE [Articulate_Stage_Test_TARGET_UAT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ART_blng__Credit_Noteline__c_Load]

AS 
BEGIN

-- =============================================
-- Version: 1.0
-- Author:	Jamison Ponko
-- Create date: 3/11/2022
-- Last Modified: 3/11/2022
-- Description:	Load CreditNoteLine Data to the Stage table in preperation to upload to Target System.
-- =============================================

-----------------------------------------------------------------------------------
-- Scripting Logic / Documentation --
-----------------------------------------------------------------------------------

/*

Source Object = KGRenewal_Invoice__c
Target Object = blng__CreditNoteLine__c

OBJECT DEPENDENCIES (These objects must exsist in Target before CreditNote can be loaded)
 - Account
 - Contact (Might not be needed)
 - blng__Invoice__c
 - blng__InvoiceLine__c
 - blng__BillingRule__c
 - blng__BillingTreatment__c
 - blng__BillingGLRule__c 
 - blng__BillingGLTreatment__c
 - Product2
 - blng__LegalEntity__c 
 - blng__CreditNote__c
 - blng__BillingFinanceBook__c
 - blng__BillingFinancePeriod__c

FILTER CRITERIA

 !Provide more documentation!


CreditNotes require CreditNote Lines and CreditNoteAllocation to function properly. blng__CreditNote__c acts as a Parent object for blng__CreditNoteLine__c

The CreditNote lines are allocated against invoice lines. The Sum of the Invoice lines must be higher then or equal to the sum of the Credit Note 

SOURCE TABLE SCHEMA

+----+----------------------------------------+--------------------------------------------------+-------------------------------------------------+--------+------------+----------+
| NO |              Field Label               |                     API Name                     |                    Data Type                    | Length | Field Type | Required |
+----+----------------------------------------+--------------------------------------------------+-------------------------------------------------+--------+------------+----------+
|  1 | Record ID                              | Id                                               | id                                              |        | Standard   | Required |
|  3 | Order/ Invoice  Item Name              | Name                                             | Text                                            |     80 | Standard   |          |
|  4 | Created Date                           | CreatedDate                                      | Date/Time                                       |        | Standard   | Required |
|  5 | Created By ID                          | CreatedById                                      | Lookup (User)                                   |        | Standard   | Required |
|  6 | Last Modified Date                     | LastModifiedDate                                 | Date/Time                                       |        | Standard   | Required |
|  7 | Last Modified By ID                    | LastModifiedById                                 | Lookup (User)                                   |        | Standard   | Required |
|  8 | System Modstamp                        | SystemModstamp                                   | Date/Time                                       |        | Standard   | Required |
|  9 | Order / Invoice                        | KGRenewal__Invoice__c                            | Master-Detail (Order / Invoice)                 |        | Custom     | Required |
| 10 | Amount                                 | KGRenewal__Amount__c                             | Currency                                        |        | Custom     | Required |
| 11 | Description Display                    | KGRenewal__DescriptionDisplay__c                 | Formula (Text)                                  |   1300 | Custom     |          |
| 12 | Description                            | KGRenewal__Description__c                        | Long Text Area                                  |    255 | Custom     |          |
| 13 | Discount Display                       | KGRenewal__DiscountDisplay__c                    | Formula (Percent)                               |        | Custom     |          |
| 14 | Discount                               | KGRenewal__Discount__c                           | Percent                                         |        | Custom     |          |
| 15 | Is Subscription                        | KGRenewal__IsSubscription__c                     | Formula (Checkbox)                              |        | Custom     |          |
| 16 | Product                                | KGRenewal__Product2__c                           | Lookup (Product)                                |        | Custom     |          |
| 17 | Product Name Display                   | KGRenewal__ProductNameDisplay__c                 | Formula (Text)                                  |   1300 | Custom     |          |
| 18 | Quantity Display                       | KGRenewal__QuantityDisplay__c                    | Formula (Number)                                |     18 | Custom     |          |
| 19 | Quantity                               | KGRenewal__Quantity__c                           | Number (10, 2)                                  |     12 | Custom     |          |
| 20 | Sort Order                             | KGRenewal__SortOrder__c                          | Number (3, 0)                                   |      3 | Custom     |          |
| 21 | Subscription Product                   | KGRenewal__SubscriptionProduct__c                | Lookup (Subscription Product)                   |        | Custom     |          |
| 22 | Unit Price Display                     | KGRenewal__UnitPriceDisplay__c                   | Formula (Currency)                              |        | Custom     |          |
| 23 | Unit Price                             | KGRenewal__UnitPrice__c                          | Currency                                        |        | Custom     |          |
| 24 | Tax Amount                             | KGRenewal__TaxAmount__c                          | Currency                                        |        | Custom     |          |
| 25 | E-Commerce Order Promotion Application | KGRenewal__ECommerceOrderPromotionApplication__c | Lookup (E-Commerce Order Promotion Application) |        | Custom     |          |
+----+----------------------------------------+--------------------------------------------------+-------------------------------------------------+--------+------------+----------+



TARGET TABLE SCHEMA - blng__CreditNoteLine__c
+----+-------------------------------------+------------------------------------------+-----------------------------+--------+------------+----------+-----------------------------------------------------------+-------------------------------------------------------------------------------------------+
| NO |             Field Label             |                 API Name                 |          Data Type          | Length | Field Type | Required |                      Picklist Values                      |                                         Help Text                                         |
+----+-------------------------------------+------------------------------------------+-----------------------------+--------+------------+----------+-----------------------------------------------------------+-------------------------------------------------------------------------------------------+
|  1 | Record ID                           | Id                                       | id                          |        | Standard   | Required |                                                           |                                                                                           |
|  3 | Line Number                         | Name                                     | Auto Number                 |     80 | Standard   | Required |                                                           |                                                                                           |
|  4 | Created Date                        | CreatedDate                              | Date/Time                   |        | Standard   | Required |                                                           |                                                                                           |
|  5 | Created By ID                       | CreatedById                              | Lookup (User)               |        | Standard   | Required |                                                           |                                                                                           |
|  6 | Last Modified Date                  | LastModifiedDate                         | Date/Time                   |        | Standard   | Required |                                                           |                                                                                           |
|  7 | Last Modified By ID                 | LastModifiedById                         | Lookup (User)               |        | Standard   | Required |                                                           |                                                                                           |
|  8 | System Modstamp                     | SystemModstamp                           | Date/Time                   |        | Standard   | Required |                                                           |                                                                                           |
|  9 | Credit Note                         | blng__CreditNote__c                      | Master-Detail (Credit Note) |        | Custom     | Required |                                                           |                                                                                           |
| 10 | Revenue Allocation Amount           | blng__AllocatedRevenueAmount__c          | Currency                    |        | Custom     |          |                                                           |                                                                                           |
| 11 | Balance                             | blng__Balance__c                         | Formula (Currency)          |        | Custom     |          |                                                           | Amount that has not yet been allocated                                                    |
| 12 | Base Currency Amount                | blng__BaseCurrencyAmount__c              | Currency                    |        | Custom     |          |                                                           |                                                                                           |
| 13 | Base Currency FX Date               | blng__BaseCurrencyFXDate__c              | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 14 | Base Currency FX Rate               | blng__BaseCurrencyFXRate__c              | Number (16, 2)              |     18 | Custom     |          |                                                           |                                                                                           |
| 15 | Base Currency                       | blng__BaseCurrency__c                    | Text                        |     20 | Custom     |          |                                                           |                                                                                           |
| 16 | Bill To Account                     | blng__BillToAccount__c                   | Lookup (Account)            |        | Custom     |          |                                                           |                                                                                           |
| 17 | Bill To Contact                     | blng__BillToContact__c                   | Lookup (Contact)            |        | Custom     |          |                                                           |                                                                                           |
| 18 | Billing Finance Book                | blng__BillingFinanceBook__c              | Lookup (Finance Book)       |        | Custom     |          |                                                           |                                                                                           |
| 19 | Billing GL Rule                     | blng__BillingGLRule__c                   | Lookup (GL Rule)            |        | Custom     |          |                                                           |                                                                                           |
| 20 | Billing GL Treatment                | blng__BillingGLTreatment__c              | Lookup (GL Treatment)       |        | Custom     |          |                                                           |                                                                                           |
| 21 | Billing Rule                        | blng__BillingRule__c                     | Lookup (Billing Rule)       |        | Custom     |          |                                                           |                                                                                           |
| 22 | Billing Treatment                   | blng__BillingTreatment__c                | Lookup (Billing Treatment)  |        | Custom     |          |                                                           |                                                                                           |
| 23 | Calculate Tax?                      | blng__CalculateTax__c                    | Checkbox                    |        | Custom     |          |                                                           |                                                                                           |
| 24 | Credit Note Line Date               | blng__CreditNoteLineDate__c              | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 25 | Effective Tax Date                  | blng__EffectiveTaxDate__c                | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 26 | End Date                            | blng__EndDate__c                         | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 27 | Finance Period                      | blng__FinancePeriod__c                   | Lookup (Finance Period)     |        | Custom     |          |                                                           |                                                                                           |
| 28 | Impact Amount                       | blng__ImpactAmount__c                    | Formula (Currency)          |        | Custom     |          |                                                           |                                                                                           |
| 29 | Invoice Line                        | blng__InvoiceLine__c                     | Lookup (Invoice Line)       |        | Custom     |          |                                                           |                                                                                           |
| 30 | LegalEntityReference                | blng__LegalEntityReference__c            | Text                        |    100 | Custom     |          |                                                           |                                                                                           |
| 31 | Legal Entity                        | blng__LegalEntity__c                     | Lookup (Legal Entity)       |        | Custom     |          |                                                           |                                                                                           |
| 32 | Net Allocations                     | blng__NetAllocations__c                  | Formula (Currency)          |        | Custom     |          |                                                           |                                                                                           |
| 33 | Notes                               | blng__Notes__c                           | Long Text Area              |  32768 | Custom     |          |                                                           |                                                                                           |
| 34 | Override Initial Revenue End Date   | blng__OverrideInitialRevenueEndDate__c   | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 35 | Override Initial Revenue Start Date | blng__OverrideInitialRevenueStartDate__c | Date                        |        | Custom     |          |                                                           |                                                                                           |
| 36 | Product Name                        | blng__ProductName__c                     | Text                        |    255 | Custom     |          |                                                           |                                                                                           |
| 37 | Product                             | blng__Product__c                         | Lookup (Product)            |        | Custom     |          |                                                           |                                                                                           |
| 38 | Refunds                             | blng__Refunds__c                         | Formula (Currency)          |        | Custom     |          |                                                           | Amount that has been refunded from this line                                              |
| 39 | Revenue Expected Amount             | blng__RevenueExpectedAmount__c           | Currency                    |        | Custom     |          |                                                           |                                                                                           |
| 40 | Revenue Liability Amount            | blng__RevenueLiabilityAmount__c          | Currency                    |        | Custom     |          |                                                           |                                                                                           |
| 41 | Revenue Most Likely Amount          | blng__RevenueMostLikelyAmount__c         | Currency                    |        | Custom     |          |                                                           |                                                                                           |
| 42 | Revenue Schedule Status             | blng__RevenueScheduleStatus__c           | Picklist                    |        | Custom     |          | Queued;Complete;Error                                     |                                                                                           |
| 43 | Start Date                          | blng__StartDate__c                       | Date                        |        | Custom     |          |                                                           | Start date of the credit line term                                                        |
| 44 | Status                              | blng__Status__c                          | Picklist                    |        | Custom     |          | Draft;Posted;Cancelled                                    | Status of the credit memo. Can be: Draft Posted Canceled                                  |
| 45 | Subtotal                            | blng__Subtotal__c                        | Currency                    |        | Custom     |          |                                                           | Unrefunded amount of the credit note. Does not include tax. Equals Amount - Refund Amount |
| 46 | Tax                                 | blng__TaxAmount__c                       | Currency                    |        | Custom     |          |                                                           | Tax amount on this line                                                                   |
| 47 | Tax City                            | blng__TaxCity__c                         | Text                        |    255 | Custom     |          |                                                           | For use in tax calculations. Destination city for this product.                           |
| 48 | Tax Code                            | blng__TaxCode__c                         | Text                        |     10 | Custom     |          |                                                           | Tax Code assigned to this line.                                                           |
| 49 | Tax Country                         | blng__TaxCountry__c                      | Text                        |    255 | Custom     |          |                                                           | For use in tax calculations. Destination city for this product.                           |
| 50 | Tax Engine                          | blng__TaxEngine__c                       | Picklist                    |        | Custom     |          | Standard;Avalara AvaTax                                   | Tax Engine that was used to calculate tax                                                 |
| 51 | Tax Error Message                   | blng__TaxErrorMessage__c                 | Text                        |    255 | Custom     |          |                                                           |                                                                                           |
| 52 | Tax GL Rule                         | blng__TaxGLRule__c                       | Lookup (GL Rule)            |        | Custom     |          |                                                           |                                                                                           |
| 53 | Tax GL Treatment                    | blng__TaxGLTreatment__c                  | Lookup (GL Treatment)       |        | Custom     |          |                                                           |                                                                                           |
| 54 | Tax Percentage Applied              | blng__TaxPercentageApplied__c            | Percent                     |        | Custom     |          |                                                           |                                                                                           |
| 55 | Tax Rule                            | blng__TaxRule__c                         | Lookup (Tax Rule)           |        | Custom     |          |                                                           |                                                                                           |
| 56 | Tax State                           | blng__TaxState__c                        | Text                        |    255 | Custom     |          |                                                           | For use in tax calculations. Destination city for this product.                           |
| 57 | Tax Status                          | blng__TaxStatus__c                       | Picklist                    |        | Custom     |          | Queued;Processing;Completed;Canceled;Error;Warning;Copied | Status of tax calculation. Can be: Pending In Process Completed Canceled Error            |
| 58 | Tax Street 2                        | blng__TaxStreet2__c                      | Text                        |    255 | Custom     |          |                                                           |                                                                                           |
| 59 | Tax Street                          | blng__TaxStreet__c                       | Text                        |    255 | Custom     |          |                                                           | For use in tax calculations. Destination city for this product.                           |
| 60 | Tax Treatment                       | blng__TaxTreatment__c                    | Lookup (Tax Treatment)      |        | Custom     |          |                                                           |                                                                                           |
| 61 | Tax Zip Code                        | blng__TaxZipCode__c                      | Text                        |     50 | Custom     |          |                                                           | For use in tax calculations. Destination city for this product.                           |
| 62 | Total Amount (With Tax)             | blng__TotalAmount__c                     | Currency                    |        | Custom     |          |                                                           | Total Amount should be same as invoice line amount                                        |
| 63 | Allocations                         | blng__Allocations__c                     | Roll-Up Summary             |        | Custom     |          |                                                           | Amount of this line allocated to invoices. Does not include tax.                          |
| 64 | Debits                              | blng__Debits__c                          | Roll-Up Summary             |        | Custom     |          |                                                           |                                                                                           |
| 65 | Refunds (Allocations)               | blng__RefundsAllocations__c              | Roll-Up Summary             |        | Custom     |          |                                                           | Amount of this line allocated to refunds                                                  |
| 66 | Refunds (Unallocations)             | blng__RefundsUnallocations__c            | Roll-Up Summary             |        | Custom     |          |                                                           | Amount of this that has been unallocated from refunds                                     |
| 67 | Unallocations                       | blng__Unallocations__c                   | Roll-Up Summary             |        | Custom     |          |                                                           | Amount of this line that has been unallocated from invoices.                              |
| 68 | Credit GL Account Name              | blngDash__Credit_GL_Account__c           | Formula (Text)              |   1300 | Custom     |          |                                                           |                                                                                           |
| 69 | Debit GL Account Name               | blngDash__Debit_GL_Account_Name__c       | Formula (Text)              |   1300 | Custom     |          |                                                           |                                                                                           |
| 70 | GL Codes                            | blngDash__GL_Codes__c                    | Formula (Text)              |   1300 | Custom     |          |                                                           |                                                                                           |
| 71 | Invoice Message                     | AVA_BLNG__Invoice_Message__c             | Long Text Area              |  32768 | Custom     |          |                                                           |                                                                                           |
+----+-------------------------------------+------------------------------------------+-----------------------------+--------+------------+----------+-----------------------------------------------------------+-------------------------------------------------------------------------------------------+

*/

---------------------------------------------------------------------------------
-- REPLICATE / REFRESH TABLES --
---------------------------------------------------------------------------------
--USE Articulate_Stage_Test_TARGET_UAT

-- Target Accounts
-- Target Users
-- Target Invoice
-- Target Invocie Lines

---------------------------------------------------------------------------------
-- Drop Staging Tables
---------------------------------------------------------------------------------
--USE [Articulate_Stage_Test_TARGET_UAT]

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='blng__CreditNoteLine__c_Load' AND TABLE_SCHEMA = 'dbo') 
--DROP TABLE blng__CreditNoteLine__c_Load;

---------------------------------------------------------------------------------
-- CREATE LOAD TABLE --
---------------------------------------------------------------------------------
--USE [Articulate_Stage_Test_TARGET_UAT]
--GO

Select 


-- Migration Fields --
	CAST(NULL AS nchar(18)) AS [ID],
	CAST('' AS nvarchar(255)) AS Error,
	A.ID AS Migration_External_ID__c, 
	
-- Audit Fields -- 
	A.CreatedDate AS CreatedDate,
	--USR.ID AS CreatedByID,

-- Date/Time Fields --
	'' AS blng__StartDate__c,
	'' AS blng__EndDate__c,

-- Lookups --
	'' AS blng__CreditNote__c,
	'' AS blng__Product__c, --
	'' blng__BillingFinanceBook__c,
	'' AS blng__BillingGLRule__c,
	'' AS blng__BillingGLTreatment__c,
	'' AS blng__BillingRule__c,
	'' AS blng__BillingTreatment__c,
	'' AS blng__LegalEntity__c, -- Hardcode this value. Unlikly to be using multiple leagle entities. 

-- Picklists --
	'Draft' AS blng__Status__c

-- Text Fields --
	--Prod.Name AS blng__ProductName__c

-- Number Fields -- 


-- CheckBox Fields --


-- Curreny Fileds --


-- Long Text Area Fields --


-- Rich Text Area Fields --


-- Email Fields --



--INTO blng__CreditNoteLine__c_Load

FROM Articulate_Stage_Test.dbo.KGRenewal__InvoiceItem__c AS A

-- JOINS --
--LEFT OUTER JOIN Articulate_Stage_Test.dbo.Account AS Account ON A.KGRenewal__Account__c = Account.Id 
--LEFT OUTER JOIN Articulate_Stage_Test_TARGET_UAT.[USER] AS USR on A.CreatedById = USR.ID
--LEFT OUTER JOIN Articulate_Stage_Test_TARGET_UAT.blng__CreditNote__c AS CN ON CN.Migration_External_ID__c = A.ID
--LEFT OUTER JOIN Product2 AS Prod ON A.KGRenewal__Product2__c = Prod.Migration_External_ID__c

--WHERE // Logic should be where the Invocie line is a negative amount. 

---------------------------------------------------------------------------------
-- LOAD CREDITNOTESLINES TO SALESFORCE -- 
---------------------------------------------------------------------------------

--EXEC SF_TABLELOADER 'Insert','ARTICULATE_STAGE_TEST_TARGET_UAT','blng__CreditNoteLine__c_Load'


-- EXTRACT CREDITNOTELINE DATA AFTER LOAD ---

/*
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Account' AND TABLE_SCHEMA = 'dbo')
DROP TABLE [dbo].[blng__CreditNote__c] ;

exec SF_BulkSOQL 'ARTICULATE_SFDC_TEST_TARGET', 'blng__CreditNote__c', '',  'SELECT Id, CreatedById, blng__Account__c, blng__Balance__c, blng__Status__c, blng__Debits__c, blng__Subtotal__c, blng__TaxAmount__c, blng__TotalAmount__c FROM blng__CreditNote__c';
*/


END