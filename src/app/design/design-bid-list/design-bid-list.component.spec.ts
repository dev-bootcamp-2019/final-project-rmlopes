import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DesignBidListComponent } from './design-bid-list.component';

describe('DesignBidListComponent', () => {
  let component: DesignBidListComponent;
  let fixture: ComponentFixture<DesignBidListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DesignBidListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DesignBidListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
