import { Component, OnInit } from '@angular/core';
import { Web3Service } from '../../util/web3.service';
import { DesignContractService } from '../design-contract.service';
import { MatSnackBar } from '@angular/material';

@Component({
  selector: 'app-design-listing',
  templateUrl: './design-listing.component.html',
  styleUrls: ['./design-listing.component.css']
})
export class DesignListingComponent implements OnInit {

  private account;
  private listings;

  constructor(private web3Service: Web3Service,
              private dService: DesignContractService,
              private matSnackBar: MatSnackBar) { }

  ngOnInit() {
    this.loadDesignList();
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 10000});
  }
  
  loadDesignList(){
    this.dService.userDesigns$.subscribe((designs) => {
      this.listings = designs;
    })
  }
}
