public with sharing class TaxReceiptsDownloadController {

 public List<Opportunity> OppList {get;set;}
 
  public Opportunity stDate {get;set;}
  public Opportunity endDate {get;set;}
  
  public List<DonationHelper> donationHelpList {get;set;}
  public Integer numDonations {get; set;}
  public Boolean allDonat {get;set;}
  
  public Set<Id> opportunityIds = new Set<Id>();
  public Boolean viewMode {get;set;}
  public Boolean chameleonWithoutEmail {get;set;}
  public Boolean includeThankYouLetters {get;set;}
  public String urlToDownload {get;set;}
  public String docName {get;set;}

  // Search Parameters
  public Date startDateParam {get; set;}
  public Date endDateParam {get; set;}
  public String taxReceiptNum {get; set;}

  // Batch job monitoring parameters
  public Id batchJobId {get; set;}
  public CSL_Batch_TaxReceiptZip batchTaxZip {get; set;}
  public List<BatchJobStatus> batchJobStatusList {get; set;}
  public boolean renderDownloadLink {get; set;}
  public List<Tax_Job_Result__c> fileNamesToDownload {get; set;}
  
  //This is the wrapper class the includes the job itself and a value for the percent complete
  public class BatchJobStatus {
    public AsyncApexJob job {get; set;}
    public Integer percentComplete {get; set;}
    public string bgStatusColor {get;set;}
    public string fgStatusColor {get;set;}


    public BatchJobStatus() {
        this.job=null;
        this.percentComplete=0;
        bgStatusColor='';
        fgStatusColor='';
    }
  }
  
  public TaxReceiptsDownloadController() {
      OppList = new List<Opportunity>();
      allDonat = true;
      viewMode = true;
      urlToDownload = '';
      endDate = new Opportunity();
       
      donationHelpList = new List<DonationHelper>();
     
      // Default date parameters
      startDateParam = System.today().toStartOfMonth();
      endDateParam = System.today();
      getDonation();
  }

  /**
    * Function to retrieve donations based on the start/end dates inclusive
    * The close date is used for the search
    */
  public void getDonation() {
     
      OppList.clear();
      donationHelpList.clear();
      batchJobId = null;

      system.debug('TaxReceiptsDownloadController :: getDonation :: startDateParam=' + startDateParam);
      system.debug('TaxReceiptsDownloadController :: getDonation :: endDateParam=' + endDateParam);
      system.debug('TaxReceiptsDownloadController :: getDonation :: endDateParam.addDays(1)=' + endDateParam.addDays(1));

      // Validate dates
      if(endDateParam < startDateParam) {
        Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'Start Date cannot be after End Date'));
      } else {
        // Query for donations between the start and end date (inclusive)
        OppList = [SELECT Id, Name, Amount, CloseDate, AccountId, Tax_Receipt_Number__c, npsp__Acknowledgment_Status__c
                     FROM Opportunity
                     WHERE 
                     (stageName = 'Posted'AND 
                     (CloseDate>=: startDateParam AND CloseDate<=: endDateParam.addDays(1)))
                     ORDER BY Name ASC];
        system.debug('TaxReceiptsDownloadController :: getDonation :: OppList=' + OppList);
      }

      // Create corresponding donation helper objects
      for(Opportunity d : OppList) {
          
            donationHelpList.add(new DonationHelper(d.Name,d.id,d.Amount,d.CloseDate.format(),d.AccountId,d.Tax_Receipt_Number__c, d.npsp__Acknowledgment_Status__c));
          }
      
      numDonations = donationHelpList.size();
    
  }

  /**
    * Function to retrieve a tax receipt based on the tax receipt number
    */
  public void getDonationByTaxNum() {
    OppList.clear();
    donationHelpList.clear();

    if(String.isEmpty(taxReceiptNum)) {
      Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'The Tax Receipt Number is Blank'));
    } else {
      
     OppList = [SELECT Id, Name, Amount, CloseDate, AccountId, Tax_Receipt_Number__c, npsp__Acknowledgment_Status__c
                     FROM Opportunity
                     WHERE 
                     (stageName = 'Posted'AND 
                     (Tax_Receipt_Number__c = :taxReceiptNum))
                     ORDER BY Name ASC];

      system.debug('TaxReceiptsDownloadController :: getDonationByTaxNum :: OppList=' + OppList);
    }

    // Create corresponding donation helper objects
    for(Opportunity d : OppList) {
          
            donationHelpList.add(new DonationHelper(d.Name,d.id,d.Amount,d.CloseDate.format(),d.AccountId,d.Tax_Receipt_Number__c, d.npsp__Acknowledgment_Status__c));
      }

    numDonations = donationHelpList.size();
  }
  

  /**
    * Helper function to select all donations on the UI
    */
  public void selectAllDonation() {
      for(DonationHelper dh : donationHelpList) {
          dh.dwnld = allDonat;
      }
  }
  

  /**
    * Method using the open source Zipex library to create a zip file
    */
  public void downloadAttachments() {
    viewMode = false;
    opportunityIds.clear();
    for(DonationHelper dh : donationHelpList){
        if(dh.dwnld){
            opportunityIds.add(dh.donId);
        }
    }
    

    if(opportunityIds.isEmpty()) {
      Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'Please select at least one Donation with tax receipt'));
    }

    batchTaxZip = new CSL_Batch_TaxReceiptZip(startDateParam, endDateParam, opportunityIds);
    batchJobId = Database.executeBatch(batchTaxZip);
    system.debug('TaxReceiptsDownloadController :: downloadAttachments :: batchJobId=' + batchJobId);
  }

  public void back() {
    viewMode = true;
  }

  public class DonationHelper{
    public Boolean dwnld {get;set;}
    public String Name {get;set;}
    public Id donId {get;set;}
    public Decimal DonAmount {get;set;}
    public String donationDate {get;set;}

    public String TaxReceipts {get;set;}
    public String acknowledgementStatus {get; set;}


    public DonationHelper(String name,String id,Decimal Amount,String CloseDate,String persName,String TaxReceipts, String acknowledgementStatus) {
      this.dwnld = true;
      this.Name = name;
      this.donId = id;
      this.DonAmount = Amount;
      this.donationDate = CloseDate;
     
      this.TaxReceipts = TaxReceipts;
      this.acknowledgementStatus = acknowledgementStatus;
   
    }
  }

  public void getBatchJobStatusList() {
      system.debug('TaxReceiptsDownloadController :: getBatchJobStatusList :: batchJobId=' + batchJobId);
      //Create new list of BatchJobs, a wrapper class that includes the job and percent complete.
      batchJobStatusList = new List<BatchJobStatus>();

      Map<String,String> bgColorMap = new Map<String,String>();
      bgColorMap.put('Queued','#f8f8f8');
      bgColorMap.put('Processing','#f8f8f8');
      bgColorMap.put('Aborted','#551A8B');
      bgColorMap.put('Completed','#f8f8f8');
      bgColorMap.put('Failed','#9E0508');
      bgColorMap.put('Preparing','#f8f8f8');

      Map<String,String> fgColorMap = new Map<String,String>();
      fgColorMap.put('Queued','#F7B64B');
      fgColorMap.put('Processing','#F7B64B');
      fgColorMap.put('Aborted','#B23AEE');
      fgColorMap.put('Completed','#20F472');
      fgColorMap.put('Failed','#FFB6C1');
      fgColorMap.put('Preparing','#F7B64B');

      //Query the Batch apex jobs
      for(AsyncApexJob aj : [ SELECT  TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, ExtendedStatus,
                                      Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name 
                              FROM AsyncApexJob 
                              WHERE JobType = 'BatchApex'
                              AND Id = :batchJobId
                              ORDER BY CreatedDate DESC LIMIT 1]) {
          
          Double itemsProcessed = aj.JobItemsProcessed;
          Double totalItems = aj.TotalJobItems;
          system.debug('CSL_VFC_LoaderStatus :: getJobStatus :: itemsProcessed=' + itemsProcessed);
          system.debug('CSL_VFC_LoaderStatus :: getJobStatus :: totalItems=' + totalItems);

          BatchJobStatus bjs = new BatchJobStatus();
          bjs.job = aj;

          // Determine the pecent complete based on the number of batches complete
          if(totalItems == 0){
              // A check here as we don't want to divide by 0.
              bjs.percentComplete = 0;
          } else {
              bjs.percentComplete = ((itemsProcessed  / totalItems) * 100.0).intValue();
          }
          system.debug('TaxReceiptsDownloadController :: getJobStatus :: bjs.percentComplete=' + bjs.percentComplete);
          String status = (!String.isEmpty(aj.ExtendedStatus)) ? 'Failed' : aj.Status;

          system.debug('TaxReceiptsDownloadController :: getJobStatus :: status=' + status);
          system.debug('TaxReceiptsDownloadController :: getJobStatus :: batchJobId=' + batchJobId);

          if(status.equalsIgnoreCase('Completed')) {
            try {
              List<Tax_Job_Result__c> tjrList = [SELECT Id, Batch_Job_File_Name__c, Batch_Job_File_Link__c
                                                 FROM Tax_Job_Result__c
                                                 WHERE Batch_Job_Id__c = :batchJobId];
              system.debug('TaxReceiptsDownloadController :: tjrList=' + tjrList);
              if(tjrList != null && (tjrList.size() > 0)) {
                renderDownloadLink = true;
                fileNamesToDownload = tjrList;
              }
            } catch (Exception ex) {
              system.debug('TaxReceiptsDownloadController :: No rows found=' + ex);
            } 
          }

          system.debug('TaxReceiptsDownloadController :: getJobStatus :: renderDownloadLink=' + renderDownloadLink);
          system.debug('TaxReceiptsDownloadController :: getJobStatus :: fileNamesToDownload=' + fileNamesToDownload);

          bjs.bgStatusColor=bgColorMap.get(status);
          bjs.fgStatusColor=fgColorMap.get(status);

          batchJobStatusList.add(bjs);
      }
    }
 
}