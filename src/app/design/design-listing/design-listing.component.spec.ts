import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DesignListingComponent } from './design-listing.component';

describe('DesignListingComponent', () => {
  let component: DesignListingComponent;
  let fixture: ComponentFixture<DesignListingComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DesignListingComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DesignListingComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
