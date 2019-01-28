import { Component, OnInit, Input, HostListener, Output, EventEmitter } from '@angular/core';
import { projection } from '@angular/core/src/render3';
import {Web3Service} from '../../util/web3.service';
import { ImageUploadComponent } from '../../simple-ipfs/image-upload/image-upload.component';
import { NewDesignBidComponent } from '../../design/new-design-bid/new-design-bid.component';
import { DesignBidListComponent } from '../../design/design-bid-list/design-bid-list.component';
import { MatSnackBar } from '@angular/material';
import { SimpleIpfsService } from '../../simple-ipfs/simple-ipfs.service';
import { TDBayService } from '../../tdbay/tdbay.service';
import {DomSanitizer, SafeResourceUrl, SafeUrl} from '@angular/platform-browser';
import { SimpleIpfsCallback } from '../../simple-ipfs/simple-ipfs-callback.interface';

declare let require: any;
const Web3 = require('web3');
const Buffer = require('buffer').Buffer;

@Component({
  selector: 'app-project-details',
  templateUrl: './project-details.component.html',
  styleUrls: ['./project-details.component.css'],
})
export class ProjectDetailsComponent extends SimpleIpfsCallback implements OnInit {

  @Input() project;
  private account;
  private isOwner;
  private editMode;
  private hideBid=true;
  //public imgPath;
  //public imgHash;

  private model = {
    Id: -1,
    State: 0,
    Name: '',
    Owner: '',
    IPFSHash: '',
    DesignId: 0,
    Description: ''
  }
  
  constructor(private web3Service: Web3Service,
              private matSnackBar: MatSnackBar,
              private ipfsService: SimpleIpfsService,
              private tdbService: TDBayService,
              sanitizer: DomSanitizer
              ) { 
    super(sanitizer);
  }

  ngOnInit() {
    console.log("Project Details OnInit: " + this.project);
    this.editMode = false;
    var i = 0;
    for(var key in this.model){
      this.model[key] = this.project[i];
      i++;
    }
    this.model.Description = Web3.utils.hexToAscii(this.model.Description);
    this.imgHash = this.model.IPFSHash;
    this.ipfsService.getIpfsImage(this);
    this.watchAccount();
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 10000});
  }

  watchAccount() {
    this.web3Service.currentAccount.subscribe(current => {
        this.account = current;
        this.isOwner = (this.model.Owner === this.account);
    });
  }

  onImgLoaded(e){
    console.log("Image Loaded " + e);
    this.imgPath = e;
  }

  onBid(e){
    this.hideBid=true;
  }

  async onSave(){
    console.log(this.imgPath);
    this.setStatus("Uploading image to IPFS. This may take a while. The transaction will be launched when it is ready.")
    this.ipfsService.addImage(this);    
  }

  async onBidAccepted(e){
    console.log("BID ACCEPTED: " + e);
    console.log(e);
      this.setStatus("Initiating transaction. Please wait...")
      try {
        var deployed = await this.tdbService.getAbstraction().deployed();

          console.log("Sending transaction from " + this.web3Service.currentAccount.value);
          console.log(this.model);
          
          var transaction = await deployed.acceptDesign.sendTransaction(
            this.model.Id, 
            e,        
            {from: this.web3Service.currentAccount.value,});
          if (!transaction) {
            this.setStatus('Transaction failed!');
          } else {
            this.setStatus('Transaction complete!');
          }
      } catch (e) {
        console.log(e);
        this.setStatus('Error accepting bid project; see log.');
    }
  }

  async ipfsImageCallback(imgHash){
      console.log(event);
      this.setStatus("Initiating transaction. Please wait...")
      try {
        var deployed = await this.tdbService.getAbstraction().deployed();
          console.log("IPFS HASH: " + imgHash);

          console.log("Sending transaction from " + this.web3Service.currentAccount.value);
          console.log(this.model);
          
          var transaction = await deployed.updateProjectFiles.sendTransaction(
            this.model.Id, 
            imgHash,        
            {from: this.web3Service.currentAccount.value,});
          if (!transaction) {
            this.setStatus('Transaction failed!');
          } else {
            this.model.IPFSHash = imgHash;
            this.imgHash = imgHash;
            this.editMode = false;
            this.setStatus('Transaction complete!');
          }
      } catch (e) {
        console.log(e);
        this.setStatus('Error creating project; see log.');
    }
  }
}
