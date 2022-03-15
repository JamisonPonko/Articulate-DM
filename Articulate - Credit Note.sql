USE [Articulate_Stage_Test_TARGET_UAT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE[dbo].[ART_blng__Credit_Note__c_Load] 

AS
BEGIN

-- =============================================
-- Version: 1.2
-- Author:	Jamison Ponko
-- Create date: 3/09/2022
-- Description:	Load CreditNote Data to the Stage table in preperation to upload to Target System.
-- =============================================

-----------------------------------------------------------------------------------
-- Scripting Logic / Documentation --
-----------------------------------------------------------------------------------
/*

SOURCE OBJECT = KGRenewal_Invoice__c
TARGET OBJECT = blng__CreditNote__c
 
ALIASES 
 - A = Articulate_Stage_Test.dbo.KGRenewal__Invoice__c
 - 

OBJECT DEPENDENCIES (These objects must exsist in Target before CreditNote can be loaded)
 - Account
 - blng__Invoice__c
 - blng__BillingFinanceBook__c
 - blng__BillingFinancePeriod__c

FILTER CRITERIA

 !Provide more documentation!


CreditNotes require CreditNote Lines and CreditNoteAllocation to function properly. blng__CreditNote__c acts as a Parent object for blng__CreditNoteLine__c. CreditNotes need to be allocated
to an Invoice via the CreditNoteLine to InvoiceLine related value on CreditNotAllocation 

The CreditNote lines are allocated against invoice lines. The Sum of the Invoice lines must be higher then or equal to the sum of the Credit Note 

SOURCE TABLE SCHEMA - KGRenewal__Invoice__c
-- +----+-------------------------------+---------------------------------------------------+---------------------------+--------+------------+----------+-------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
-- | NO |          Field Label          |                     API Name                      |         Data Type         | Length | Field Type | Required |                       Picklist Values                       |                                                                                            Help Text                                                                                            |
-- +----+-------------------------------+---------------------------------------------------+---------------------------+--------+------------+----------+-------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
-- |  1 | Record ID                     | Id                                                | id                        |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  2 | Deleted                       | IsDeleted                                         | Checkbox                  |        | Standard   |          |                                                             |                                                                                                                                                                                                 |
-- |  3 | Order/ Invoice Name           | Name                                              | Auto Number               |     80 | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  4 | Created Date                  | CreatedDate                                       | Date/Time                 |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  5 | Created By ID                 | CreatedById                                       | Lookup (User)             |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  6 | Last Modified Date            | LastModifiedDate                                  | Date/Time                 |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  7 | Last Modified By ID           | LastModifiedById                                  | Lookup (User)             |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  8 | System Modstamp               | SystemModstamp                                    | Date/Time                 |        | Standard   | Required |                                                             |                                                                                                                                                                                                 |
-- |  9 | Last Activity Date            | LastActivityDate                                  | Date                      |        | Standard   |          |                                                             |                                                                                                                                                                                                 |
-- | 10 | Last Viewed Date              | LastViewedDate                                    | Date/Time                 |        | Standard   |          |                                                             |                                                                                                                                                                                                 |
-- | 11 | Last Referenced Date          | LastReferencedDate                                | Date/Time                 |        | Standard   |          |                                                             |                                                                                                                                                                                                 |
-- | 12 | Account                       | KGRenewal__Account__c                             | Master-Detail (Account)   |        | Custom     | Required |                                                             |                                                                                                                                                                                                 |
-- | 13 | Adjustment Amount             | KGRenewal__AdjustmentAmount__c                    | Currency                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 14 | Adjustment Description        | KGRenewal__AdjustmentDescription__c               | Long Text Area            |  32768 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 15 | Amount Due                    | KGRenewal__AmountDue__c                           | Formula (Currency)        |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 16 | Amount Paid                   | KGRenewal__AmountPaid__c                          | Currency                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 17 | Amount                        | KGRenewal__Amount__c                              | Currency                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 18 | Order / Invoicing Date        | KGRenewal__BillingDate__c                         | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 19 | Contact                       | KGRenewal__Contact__c                             | Lookup (Contact)          |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 20 | Billing/Due Date              | KGRenewal__DueDate__c                             | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 21 | Order / Invoice Sent          | KGRenewal__InvoiceSent__c                         | Checkbox                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 22 | Closed                        | KGRenewal__IsClosed__c                            | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 23 | Merged Into                   | KGRenewal__MergedIntoInvoice__c                   | Lookup (Order / Invoice)  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 24 | Online Payment Key            | KGRenewal__OnlinePaymentKey__c                    | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 25 | Opportunity                   | KGRenewal__Opportunity__c                         | Lookup (Opportunity)      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 26 | Payment Attempts              | KGRenewal__PaymentAttempts__c                     | Number (18, 0)            |     18 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 27 | End Date                      | KGRenewal__PeriodEnd__c                           | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 28 | Start Date                    | KGRenewal__PeriodStart__c                         | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 29 | Status                        | KGRenewal__Status__c                              | Picklist                  |        | Custom     |          | Future;Open;Past Due;Paid;Aborted;Failed;Merged             |                                                                                                                                                                                                 |
-- | 30 | Subscription                  | KGRenewal__Subscription__c                        | Lookup (Subscription)     |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 31 | Total Amount                  | KGRenewal__TotalAmount__c                         | Formula (Currency)        |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 32 | Item Subtotal                 | KGRenewal__ItemSubtotal__c                        | Roll-Up Summary           |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 33 | Tax                           | KGRenewal__Tax__c                                 | Roll-Up Summary           |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 34 | Adjusted Subtotal             | KGRenewal__AdjustedSubtotal__c                    | Formula (Currency)        |        | Custom     |          |                                                             | The sum of all Invoice Item amounts plus any added adjustment amount.                                                                                                                           |
-- | 35 | Disable Automation            | KGRenewal__DisableAutomaticInvoicingAndBilling__c | Checkbox                  |        | Custom     |          |                                                             | If true, this invoice will not be automatically sent or billed by Encore. Invoice Status values will still be updated and this invoice can still be manually sent and billed.                   |
-- | 36 | Order Comments                | Order_Comments__c                                 | Rich Text Area            |  32768 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 37 | Manual Confirmation Address   | Manual_Confirmation_Address__c                    | Email                     |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 38 | Subscription Status           | Subscription_Status__c                            | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 39 | Script Update                 | Script_Update__c                                  | Picklist                  |        | Custom     |          | SFDC-400;SFDC-1019;SFDC-808;SFDC-1327;SFDC-1355;SFDC-1327_2 |                                                                                                                                                                                                 |
-- | 40 | Tax Adjustment                | Tax_Adjustment__c                                 | Formula (Checkbox)        |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 41 | Payment Mix                   | Payment_Mix__c                                    | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 42 | Processed By Batch Activation | Processed_By_Batch_Activation__c                  | Checkbox                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 43 | E-Commerce Order              | KGRenewal__ECommerceOrder__c                      | Lookup (E-Commerce Order) |        | Custom     |          |                                                             | The order providing payment for this Invoice.                                                                                                                                                   |
-- | 44 | Accounting Status             | Accounting_Status__c                              | Picklist                  |        | Custom     |          | Open;Paid                                                   | The status of the Invoice according to Articulates Accounting department                                                                                                                        |
-- | 45 | Accounting Transaction Type   | PO_Accounting_Transaction_Type__c                 | Text                      |    100 | Custom     |          |                                                             | Used to store the field value from the transaction to tell if the invoice was paid by either PO or CC. If multiple mixed transactions (cc and PO) then the value will be set to Purchase Order. |
-- | 46 | CC Transactions               | CC_Transactions__c                                | Number (4, 0)             |      4 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 47 | Internal Subscription         | KGRenewal__IsInternalSubscription__c              | Formula (Checkbox)        |        | Custom     |          |                                                             | If the Invoice's Subscription is internal, this field will be true.                                                                                                                             |
-- | 48 | Subscription Payment Type     | Subscription_Payment_Type__c                      | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 49 | Partner Access                | Partner_Access__c                                 | Formula (Checkbox)        |        | Custom     |          |                                                             | Allows partners to access their own invoices                                                                                                                                                    |
-- | 50 | Contract Effective Date       | KGRenewal__ContractEffectiveDate__c               | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 51 | Contract End Date             | KGRenewal__ContractEndDate__c                     | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 52 | Period                        | KGRenewal__Period__c                              | Number (16, 2)            |     18 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 53 | Term (in months)              | KGRenewal__Term__c                                | Number (3, 2)             |      5 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 54 | AvaTax Id                     | AvaTax_Id__c                                      | Text                      |     18 | Custom     |          |                                                             | Unique Identifier from Avalara for this transaction                                                                                                                                             |
-- | 55 | Tax Committed Date            | Tax_Committed_Date__c                             | Text                      |    255 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 56 | Tax Status                    | Tax_Status__c                                     | Text                      |    255 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 57 | In Accounting Extracts        | In_Accounting_Extracts__c                         | Checkbox                  |        | Custom     |          |                                                             | Used to denote if an invoice was exported to an accounting extract.                                                                                                                             |
-- | 58 | Accounting Extract Feed       | Accounting_Extract_Feed__c                        | Text                      |    200 | Custom     |          |                                                             | Which accounting extract feed was the invoice found in                                                                                                                                          |
-- | 59 | Invoice Payment Date          | KGRenewal__InvoicePaymentDate__c                  | Date                      |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 60 | Invoice Bug                   | Invoice_Bug__c                                    | Formula (Checkbox)        |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 61 | Applied Account Balance       | KGRenewal__AppliedAccountBalance__c               | Currency                  |        | Custom     |          |                                                             | Amount deducted from the associated account’s balance to pay the invoice.                                                                                                                       |
-- | 62 | External Access Token         | KGRenewal__ExternalAccessToken__c                 | Text                      |    255 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 63 | Is Proforma                   | KGRenewal__IsProforma__c                          | Checkbox                  |        | Custom     |          |                                                             | If true this Invoice is a Proforma Invoice.                                                                                                                                                     |
-- | 64 | Visible to Guest Users        | KGRenewal__IsVisibleToGuestUsers__c               | Checkbox                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 65 | Shipping                      | KGRenewal__Shipping__c                            | Currency                  |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 66 | Purchaser Contact Email       | Purchaser_Contact_Email__c                        | Formula (Text)            |   1300 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 67 | Additional Email Address      | Additional_Email_Address__c                       | Text                      |    255 | Custom     |          |                                                             | CC Email Invoice for Billing Terminal                                                                                                                                                           |
-- | 68 | Item Count                    | Item_Count__c                                     | Roll-Up Summary           |     18 | Custom     |          |                                                             | How many invoice items are on this invoice?                                                                                                                                                     |
-- | 69 | Non Item Tax                  | KGRenewal__NonItemTax__c                          | Currency                  |        | Custom     |          |                                                             | Non item tax includes the tax on shipping.                                                                                                                                                      |
-- | 70 | Total Tax                     | KGRenewal__TotalTax__c                            | Formula (Currency)        |        | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- | 71 | PO Transactions               | PO_Transactions__c                                | Number (4, 0)             |      4 | Custom     |          |                                                             |                                                                                                                                                                                                 |
-- +----+-------------------------------+---------------------------------------------------+---------------------------+--------+------------+----------+-------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


TARGET TABLE SCHEMA - blng__CreditNote__c
-- +----+---------------------------+---------------------------------+-------------------------+--------+------------+----------+-----------------------------------------------------------------------------+
-- | NO |        Field Label        |            API Name             |        Data Type        | Length | Field Type | Required |                               Picklist Values                               |
-- +----+---------------------------+---------------------------------+-------------------------+--------+------------+----------+-----------------------------------------------------------------------------+
-- |  1 | Record ID                 | Id                              | id                      |        | Standard   | Required |                                                                             |
-- |  2 | Deleted                   | IsDeleted                       | Checkbox                |        | Standard   |          |                                                                             |
-- |  3 | Credit Note Number        | Name                            | Auto Number             |     80 | Standard   | Required |                                                                             |
-- |  4 | Created Date              | CreatedDate                     | Date/Time               |        | Standard   | Required |                                                                             |
-- |  5 | Created By ID             | CreatedById                     | Lookup (User)           |        | Standard   | Required |                                                                             |
-- |  6 | Last Modified Date        | LastModifiedDate                | Date/Time               |        | Standard   | Required |                                                                             |
-- |  7 | Last Modified By ID       | LastModifiedById                | Lookup (User)           |        | Standard   | Required |                                                                             |
-- |  8 | System Modstamp           | SystemModstamp                  | Date/Time               |        | Standard   | Required |                                                                             |
-- |  9 | Last Viewed Date          | LastViewedDate                  | Date/Time               |        | Standard   |          |                                                                             |
-- | 10 | Last Referenced Date      | LastReferencedDate              | Date/Time               |        | Standard   |          |                                                                             |
-- | 11 | Account                   | blng__Account__c                | Master-Detail (Account) |        | Custom     | Required |                                                                             |
-- | 12 | Balance                   | blng__Balance__c                | Formula (Currency)      |        | Custom     |          |                                                                             |
-- | 13 | Base Currency Amount      | blng__BaseCurrencyAmount__c     | Currency                |        | Custom     |          |                                                                             |
-- | 14 | Base Currency FX Date     | blng__BaseCurrencyFXDate__c     | Date                    |        | Custom     |          |                                                                             |
-- | 15 | Base Currency FX Rate     | blng__BaseCurrencyFXRate__c     | Number (16, 2)          |     18 | Custom     |          |                                                                             |
-- | 16 | Base Currency             | blng__BaseCurrency__c           | Text                    |     20 | Custom     |          |                                                                             |
-- | 17 | Bill To Account           | blng__BillToAccount__c          | Lookup (Account)        |        | Custom     |          |                                                                             |
-- | 18 | Bill To Contact           | blng__BillToContact__c          | Lookup (Contact)        |        | Custom     |          |                                                                             |
-- | 19 | Billing Finance Book      | blng__BillingFinanceBook__c     | Lookup (Finance Book)   |        | Custom     |          |                                                                             |
-- | 20 | Billing Finance Period    | blng__BillingFinancePeriod__c   | Lookup (Finance Period) |        | Custom     |          |                                                                             |
-- | 21 | Credit Note Date          | blng__CreditNoteDate__c         | Date                    |        | Custom     | Required |                                                                             |
-- | 22 | Credit Note Source Action | blng__CreditNoteSourceAction__c | Picklist                |        | Custom     |          | Cancel & Rebill;Credit;Invoice Line Credit;Negative Lines Conversion;Manual |
-- | 23 | Effective Tax Date        | blng__EffectiveTaxDate__c       | Date                    |        | Custom     |          |                                                                             |
-- | 24 | Estimate Tax Process Time | blng__EstimateTaxProcessTime__c | Number (18, 0)          |     18 | Custom     |          |                                                                             |
-- | 25 | Impact Amount             | blng__ImpactAmount__c           | Formula (Currency)      |        | Custom     |          |                                                                             |
-- | 26 | Net Allocations           | blng__NetAllocations__c         | Formula (Number)        |     18 | Custom     |          |                                                                             |
-- | 27 | Notes                     | blng__Notes__c                  | Long Text Area          |  32768 | Custom     |          |                                                                             |
-- | 28 | Source Invoice            | blng__RelatedInvoice__c         | Lookup (Invoice)        |        | Custom     |          |                                                                             |
-- | 29 | Status                    | blng__Status__c                 | Picklist                |        | Custom     |          | Draft;Posted;Cancelled                                                      |
-- | 30 | Tax City                  | blng__TaxCity__c                | Text                    |    255 | Custom     |          |                                                                             |
-- | 31 | Tax Country               | blng__TaxCountry__c             | Text                    |    255 | Custom     |          |                                                                             |
-- | 32 | Tax Error Message         | blng__TaxErrorMessage__c        | Text                    |    255 | Custom     |          |                                                                             |
-- | 33 | Tax State                 | blng__TaxState__c               | Text                    |    255 | Custom     |          |                                                                             |
-- | 34 | Tax Street 2              | blng__TaxStreet2__c             | Text                    |    255 | Custom     |          |                                                                             |
-- | 35 | Tax Street 1              | blng__TaxStreet__c              | Text                    |    255 | Custom     |          |                                                                             |
-- | 36 | Tax Postal Code           | blng__TaxZipCode__c             | Text                    |    255 | Custom     |          |                                                                             |
-- | 37 | Allocations               | blng__Allocations__c            | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 38 | Debits                    | blng__Debits__c                 | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 39 | Refunds                   | blng__Refunds__c                | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 40 | Subtotal                  | blng__Subtotal__c               | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 41 | Tax                       | blng__TaxAmount__c              | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 42 | Total Amount (With Tax)   | blng__TotalAmount__c            | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- | 43 | Unallocations             | blng__Unallocations__c          | Roll-Up Summary         |        | Custom     |          |                                                                             |
-- +----+---------------------------+---------------------------------+-------------------------+--------+------------+----------+-----------------------------------------------------------------------------+

*/


---------------------------------------------------------------------------------
-- DROP STAGING TABLES
---------------------------------------------------------------------------------
--USE [Articulate_Stage_Test_TARGET_UAT]

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='blng__CreditNote__c_Load' AND TABLE_SCHEMA = 'dbo') 
--DROP TABLE blng__CreditNote__c_Load;

---------------------------------------------------------------------------------
-- REPLICATE / REFRESH TABLES --
---------------------------------------------------------------------------------

-- Target Accounts
-- Target Users
-- Target Invoice
-- 

---------------------------------------------------------------------------------
-- CREATE LOAD TABLE --
---------------------------------------------------------------------------------
--USE [Articulate_Stage_Test_TARGET_UAT]
--GO

Select 

-- Migration Fields --
	CAST(NULL AS nchar(18)) AS [ID],
	CAST('' AS nvarchar(255)) AS Error,
	A.ID AS Migration_External_ID__c, -- Renewal Invoice ID
	
-- Audit Fields -- 
	A.CreatedDate AS CreatedDate, -- Add User lookup Join for Target USER IDs 
	USR.ID AS CreatedById,

-- Date Fields --
	A.CreatedDate AS blng__CreditNoteDate__c,

-- Lookups --
	A.KGRenewal__Account__c AS blng__Account__c, -- To be replaced with Account.ID
	-- inv2.ID as blng__RelatedInvoice__c,
	-- '' AS blng__BillingFinanceBook__c -- Potentially might need to hard code this value
	-- '' AS blng__BillingFinancePeriod__c -- Potentially might need to hard code this value

-- Picklists --
	'Draft' AS blng__Status__c,

-- Text Fields --
	Account.BillingCity AS blng__TaxCity__c,
	Account.BillingCountry AS blng__TaxCountry__c,
	Account.BillingState AS blng__TaxState__c,
	Account.BillingStreet AS blng__TaxStreet__c,
	Account.BillingPostalCode AS blng__TaxZipCode__c

--INTO blng__CreditNote__c_Load

FROM Articulate_Stage_Test.dbo.KGRenewal__Invoice__c AS A

LEFT OUTER JOIN Articulate_Stage_Test.dbo.Account AS Account ON A.KGRenewal__Account__c = Account.Id -- Remove this JOIN and replace with JOIN 1. (TEST JOIN 0)
--LEFT OUTER JOIN Articulate_Stage_Test_TARGET_UAT.dbo.Account AS Account on A.KGRenewal__Account__c = Account.Migration_External_ID__c -- JOIN 1
--LEFT OUTER JOIN blng__Invoice__c AS INV on INV.Migration_External_ID__c = A.KGRenewal__MergedIntoInvoice__c -- JOIN 2
--LEFT OUTER JOIN Articulate_Stage_Test.dbo.KGRenewal_Invoice__c inv on a.KGRenewal__MergedIntoInvoice__c = inv.KGRenewal__MergedIntoInvoice__c AND a.KGRenewal__Amount__c NOT LIKE '%-%' -- JOIN 3 
--LEFT OUTER JOIN blng__Invoice__c inv2 on inv2.Migration_External_ID__c = a.KGRenewal__MergedIntoInvoice__c -- JOIN 4
LEFT OUTER JOIN Articulate_Stage_Test_TARGET_UAT.dbo.[USER] AS USR ON USR.Migration_External_ID__c = A.CreatedById -- JOIN 5

--WHERE A.KGRenewal__MergedIntoInvoice__c is not null AND a.KGRenewal__Amount__c LIKE '%-%'

---------------------------------------------------------------------------------
-- INSERT/UPDATE RECORDS TO SALESFORCE -- 
---------------------------------------------------------------------------------
-- USE XYZ

-- EXEC SF_TABLELOADER 'Upsert','ARTICULATE_STAGE_TEST_TARGET_UAT','blng__CreditNote__c_Load', 'Migration_External_ID__c'

-- SELECT * FROM blng__CreditNote__c_Load_Results WHERE ERROR NOT LIKE %success%


---------------------------------------------------------------------------------
-- EXTRACT CREDITNOTE DATA AFTER LOAD ---
---------------------------------------------------------------------------------

/*
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Account' AND TABLE_SCHEMA = 'dbo')
DROP TABLE [dbo].[blng__CreditNote__c] ;

exec SF_BulkSOQL 'ARTICULATE_SFDC_TEST_TARGET', 'blng__CreditNote__c', '',  'SELECT Id, CreatedById, blng__Account__c, blng__Balance__c, blng__Status__c, blng__Debits__c, blng__Subtotal__c, blng__TaxAmount__c, blng__TotalAmount__c FROM blng__CreditNote__c';
*/


END

