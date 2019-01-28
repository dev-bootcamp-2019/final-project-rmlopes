import { Component, OnInit, Input, AfterContentInit, Output, EventEmitter } from '@angular/core';
import { DesignContractService } from '../design-contract.service';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-design-bid-list',
  templateUrl: './design-bid-list.component.html',
  styleUrls: ['./design-bid-list.component.css'],
  providers: [DesignContractService]
})
export class DesignBidListComponent implements OnInit,AfterContentInit {

  @Input() projectId: any;
  @Input() projectOwner: string;
  @Input() projectState: any;
  @Output() bidAccepted = new EventEmitter<any>();
  private bids;
  private abstraction;

  constructor(private dService: DesignContractService) { 
  }

  ngOnInit() {
    console.log("Design Bid listing OnInit");
  }

  ngAfterContentInit(): void{
    this.prepareBids();
  }

  // async getBids() {
  //   this.dService.getAbstraction().then((abstraction)=>{
  //     abstraction.deployed().then((deployed)=>{
  //           deployed.getDesigns.call(this.projectId).then((bids)=>{
  //             this.bids = bids;
  //           });
  //       });
  //   });
  //   // const deployed = await abstraction.deployed();
  //   // const bids = await deployed.getDesigns.call(this.projectId);
  //   // this.bids = bids;
  //   // console.log("Found bids " + this.bids);
  // }

  async prepareBids(){
    this.dService.getAbstraction().subscribe((abstraction)=>{
      abstraction.deployed().then((deployed)=>{
        deployed.getDesigns.call(this.projectId).then((bids)=>{
          this.bids = bids;
        });
    });
    });
  }

  onBidAccepted(e){
    this.bidAccepted.emit(e);
  }
}
