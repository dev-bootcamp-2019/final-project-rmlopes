import { Component, OnInit, Input, Output, EventEmitter} from '@angular/core';
import { projectionDef } from '@angular/core/src/render3';
import { DesignContractService } from '../design-contract.service';

@Component({
  selector: 'app-new-design-bid',
  templateUrl: './new-design-bid.component.html',
  styleUrls: ['./new-design-bid.component.css']
})
export class NewDesignBidComponent implements OnInit {

  @Input() projectId;
  @Input() projectName;
  @Output() bidAdded = new EventEmitter();
  
  model = {
    designCost: 0,
    description: ''
  }

  constructor(private designService: DesignContractService) { }

  ngOnInit() {
  }

  setCost(e){
    this.model.designCost = e.target.value;
  }

  setDescription(e){
    console.log("Setting new design bid description: "+e.target.value);
    this.model.description = e.target.value;
  }

  placeBid(){
    console.log("Placing design bid on project " + this.projectName);
    this.designService.addDesignBid(this.projectId, this.model.designCost, this.model.description);
    this.bidAdded.emit();
  }

}
