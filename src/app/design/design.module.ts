import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {UtilModule} from '../util/util.module';
import {RouterModule} from '@angular/router';

import {
  MatButtonModule,
  MatCardModule,
  MatFormFieldModule,
  MatInputModule,
  MatOptionModule,
  MatSelectModule, MatSnackBarModule, MatGridList, MatGridListModule, MatExpansionModule
} from '@angular/material';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import { NewDesignBidComponent } from './new-design-bid/new-design-bid.component';
import { DesignAdminComponent } from './design-admin/design-admin.component';
import { DesignBidDetailsComponent } from './design-bid-details/design-bid-details.component';
import { DesignBidListComponent } from './design-bid-list/design-bid-list.component';
import { DesignListingComponent } from './design-listing/design-listing.component';
import { SimpleIpfsModule } from '../simple-ipfs/simple-ipfs.module';

@NgModule({
  imports: [
    BrowserAnimationsModule,
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatOptionModule,
    MatSelectModule,
    MatSnackBarModule,
    MatGridListModule,
    MatExpansionModule,
    SimpleIpfsModule,
    RouterModule,
    UtilModule
  ],
  declarations: [NewDesignBidComponent, DesignAdminComponent, DesignBidDetailsComponent, DesignBidListComponent, DesignListingComponent],
  exports: [NewDesignBidComponent, DesignAdminComponent, DesignBidListComponent]
})
export class DesignModule { }
