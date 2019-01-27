import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DesignBidDetailsComponent } from './design-bid-details.component';

describe('DesignBidDetailsComponent', () => {
  let component: DesignBidDetailsComponent;
  let fixture: ComponentFixture<DesignBidDetailsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DesignBidDetailsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DesignBidDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
