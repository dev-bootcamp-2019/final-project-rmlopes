import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProjectListingComponent } from './project-listing/project-listing.component';
import { NewProjectComponent } from './new-project/new-project.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatExpansionModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatOptionModule, MatSelectModule, MatSnackBarModule } from '@angular/material';
import { MatGridListModule } from '@angular/material/grid-list';
import { RouterModule } from '@angular/router';
import { UtilModule } from '../util/util.module';
import { ProjectDetailsComponent } from './project-details/project-details.component';
import { NewDesignBidComponent } from '../design/new-design-bid/new-design-bid.component';
import { SimpleIpfsModule } from '../simple-ipfs/simple-ipfs.module';
import { DesignModule } from '../design/design.module';
import { OwnerProjectListComponent } from './owner-project-list/owner-project-list.component';

@NgModule({
  declarations: [ProjectListingComponent, NewProjectComponent, ProjectDetailsComponent, OwnerProjectListComponent],
  
  imports: [
    BrowserAnimationsModule,
    CommonModule,
    MatGridListModule,
    MatExpansionModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatOptionModule,
    MatSelectModule,
    MatSnackBarModule,
    SimpleIpfsModule,
    DesignModule,
    RouterModule,
    UtilModule
  ],
})
export class ProjectsModule { }
