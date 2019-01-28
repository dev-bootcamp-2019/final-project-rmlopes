import { Component, OnInit, Input, EventEmitter, Output } from '@angular/core';
import { DesignContractService } from '../design-contract.service';
import { SimpleIpfsCallback } from '../../simple-ipfs/simple-ipfs-callback.interface';
import { DomSanitizer } from '@angular/platform-browser';
import { SimpleIpfsService } from '../../simple-ipfs/simple-ipfs.service';
import { Web3Service } from '../../util/web3.service';
import { MatSnackBar } from '@angular/material';

@Component({
  selector: 'app-design-bid-details',
  templateUrl: './design-bid-details.component.html',
  styleUrls: ['./design-bid-details.component.css']
})
export class DesignBidDetailsComponent extends SimpleIpfsCallback implements OnInit {
  

  @Input() bidId;
  @Input() projectOwner;
  @Output() bidAccepted = new EventEmitter();
  private editMode;
  private account;
  private isOwner = false;
  private isProjectOwner = false;

  model = {
    state: 0,
    cost: 0,
    owner: '',
    description: ''
  }
  
  constructor(private dService: DesignContractService, 
              public sanitizer: DomSanitizer,
              private ipfsService: SimpleIpfsService,
              private web3Service: Web3Service,
              private matSnackBar: MatSnackBar) { 
    super(sanitizer);
    this.account = dService.account;
    console.log("Design Bid Details: "+this.account);
  }

  ngOnInit() {
    this.watchAccount();
    this.loadDetails();
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 10000});
  }

  watchAccount() {
    this.web3Service.currentAccount.subscribe(current => {
          this.account = current;
      });
  }

  async loadDetails(){
    console.log("Laoding bid details. ");
    const deployed = await this.dService.Design.deployed();
    const state = await deployed.getState.call(this.bidId);
    const previewFiles = await deployed.getPreviewFiles.call(this.bidId);
    const files = await deployed.getDesignFiles.call(this.bidId);
    const cost = await deployed.getDesignCost.call(this.bidId);
    const owner = await deployed.getOwner.call(this.bidId);
    const description = await deployed.getDescription.call(this.bidId);
    this.imgHash = previewFiles;
    if(previewFiles != '')
      this.ipfsService.getIpfsImage(this);
    this.model.state = state;
    this.model.cost = cost;
    this.model.owner = owner;
    this.model.description = description;
    console.log(this.model);
    this.isProjectOwner = (this.account === this.projectOwner);
    this.isOwner = (this.model.owner === this.account);

  }

  async ipfsImageCallback(imgHash: string){
    console.log(event);
      this.setStatus("Initiating transaction. Please wait...")
      try {
        var deployed = await this.dService.Design.deployed();
          console.log("IPFS HASH: " + imgHash);

          console.log("Sending transaction from " + this.web3Service.currentAccount.value);
          console.log(this.model);
          
          var transaction = await deployed.updatePreview.sendTransaction(
            this.bidId, 
            imgHash,        
            {from: this.web3Service.currentAccount.value,});
          if (!transaction) {
            this.setStatus('Transaction failed!');
          } else {
            this.imgInitialized = true;
            this.setStatus('Transaction complete!');
          }
      } catch (e) {
        console.log(e);
        this.setStatus('Error creating project; see log.');
    }
  }

  onImgLoaded(e){
    console.log("Image Loaded " + e);
    this.imgPath = e;
  }

  onAcceptBid(){
    this.bidAccepted.emit();
  }

  onSave(){
    console.log(this.imgPath);
    this.setStatus("Uploading image to IPFS. This may take a while. The transaction will be launched when it is ready.")
    this.editMode = false;
    this.ipfsService.addImage(this);
  }
}
