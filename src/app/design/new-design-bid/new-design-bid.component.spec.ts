import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { NewDesignBidComponent } from './new-design-bid.component';

describe('NewDesignBidComponent', () => {
  let component: NewDesignBidComponent;
  let fixture: ComponentFixture<NewDesignBidComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ NewDesignBidComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(NewDesignBidComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
