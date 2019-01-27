import { Component, OnInit, Input, ViewChild, ɵConsole } from '@angular/core';
import {Web3Service} from '../../util/web3.service';
import { MatSnackBar } from '@angular/material';
import { SimpleIpfsService } from '../../simple-ipfs/simple-ipfs.service';
import { SimpleIpfsCallback } from '../../simple-ipfs/simple-ipfs-callback.interface';
import { DomSanitizer } from '@angular/platform-browser';

declare let require: any;
const tdbay_artifacts = require('../../../../build/contracts/TDBay.json');
const Web3 = require('web3');

@Component({
  selector: 'app-new-project',
  templateUrl: './new-project.component.html',
  styleUrls: ['./new-project.component.css']
})

export class NewProjectComponent extends SimpleIpfsCallback  implements OnInit {

  private TDBay;
  private imgBuffer;

  model = {
    name: '',
    description: ''
  }

  constructor(private web3Service: Web3Service, 
              private matSnackBar: MatSnackBar,
              private ipfsService: SimpleIpfsService,
              public sanitizer: DomSanitizer) { 
    super(sanitizer);
  }

  ngOnInit() {
    console.log('OnInit: ' + this.web3Service);
    this.web3Service.artifactsToContract(tdbay_artifacts)
      .then((TDBayAbstraction) => {
        this.TDBay = TDBayAbstraction;
        this.TDBay.deployed().then(deployed => {
          console.log(deployed);
        });

      });
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 3000});
  }

  setNewName(e){
    console.log("Setting new project name: "+e.target.value);
    this.model.name = e.target.value;
  }

  setDescription(e){
    console.log("Setting new project description: "+e.target.value);
    this.model.description = e.target.value;
  }

  async addProject(){
    this.setStatus("Uploading image to IPFS. This may take a while. The transaction will be launched when it is ready.")
    this.ipfsService.addImage(this);
  }

  async ipfsImageCallback(imgHash){
    this.setStatus("Initiating transaction. Please wait...")
    try {
      var deployed = await this.TDBay.deployed();
      var cost = await deployed.projectCost.call();

        console.log("IPFS HASH: " + imgHash);

        console.log("Sending transaction from " + this.web3Service.currentAccount.value + "with value "+cost);
        console.log(this.model.description);
        var hexDescription = Web3.utils.asciiToHex(this.model.description);
        var transaction = await deployed.addProject.sendTransaction(
          this.model.name, 
          hexDescription,
          imgHash,        
          {from: this.web3Service.currentAccount.value,
          value: cost});
        if (!transaction) {
          this.setStatus('Transaction failed!');
        } else {
          this.setStatus('Transaction complete!');
        }
    } catch (e) {
      console.log(e);
      this.setStatus('Error creating project; see log.');
    }
  }

  preview(files) {
    if (files.length === 0)
      return;
 
    var mimeType = files[0].type;
    if (mimeType.match(/image\/*/) == null) {
      this.setStatus("Only images are supported.");
      return;
    }
 
    var reader = new FileReader();
    this.imgPath = files[0];
    reader.readAsDataURL(files[0]); 
    reader.onload = (_event) => { 
      this.imgURL = reader.result; 
    }
  }
}
