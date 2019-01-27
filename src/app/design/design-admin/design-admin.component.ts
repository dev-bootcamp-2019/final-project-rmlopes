import { Component, OnInit } from '@angular/core';
import { DesignContractService } from '../design-contract.service';
import { Web3Service } from '../../util/web3.service';

declare let require: any;
const design_artifacts = require('../../../../build/contracts/Design.json');

@Component({
  selector: 'app-design-admin',
  templateUrl: './design-admin.component.html',
  styleUrls: ['./design-admin.component.css']
})
export class DesignAdminComponent implements OnInit {

  private Design;

  model = {
    masterContract: '0x00'
  }

  constructor(private dService: DesignContractService,
              private web3Service: Web3Service) { 
    this.web3Service.artifactsToContract(design_artifacts)
      .then((DesignAbstraction) => {
        this.Design = DesignAbstraction;
        this.Design.deployed().then(deployed => {
          console.log(deployed);
          this.getMaster(deployed);
      });
    });
  }

  ngOnInit() {
  }

  setCurrentMasterContract(){
    this.dService.setMaster();
  }

  async getMaster(deployed){
    var master = await deployed.getMaster.call();
    this.model.masterContract = master;
  }

  setMasterContract(e){
    this.model.masterContract = e.target.value;
  }

  updateMasterContract(){

  }

}
