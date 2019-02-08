//
//  ObservableType.swift
//  MyBroker
//
//  Created by Alexej Nenastev on 26.02.2018.
//  Copyright © 2018 BCS. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Observable where Element: OptionalType, Element.Wrapped == Int {

    func nilToZero() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.just(0)
        }
    }
}

public extension Observable where Element: OptionalType, Element.Wrapped == Double {

    func nilToZero() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.just(0)
        }
    }
}

public extension Observable where Element: OptionalType {

    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.empty()
        }
    }
}

public extension ObservableType where E == Bool {

   func bindsIsHidden(bag: DisposeBag, to views: UIView?...) {
        let shared = self.share()
        views.compactMap { $0 }.forEach { shared.bind(to: $0.rx.isHidden).disposed(by: bag) }
    }

    func throttleOnlyTrue(_ dueTime: RxTimeInterval, scheduler: SchedulerType) -> Observable<Bool> {
        return flatMapLatest {
            $0 ? Observable.just(true).delay(dueTime, scheduler: scheduler) : Observable.just(false)
        }
    }
}

public extension ObservableType where Self.E == Any {

     static func timerWithTrigger(trigger: Observable<Bool>, timer: Observable<Int>) -> Observable<Void> {
        return Observable.combineLatest(trigger, timer)
            .flatMapLatest {
                $0.0 ? Observable<Int64>.interval(RxTimeInterval($0.1), scheduler: MainScheduler.instance).startWith(0).map { _ in () } : .empty() }
    }
}

public extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait {
    
    func subscribe<T: AnyObject>(_ instance: T,
                                 complete classFunc: @escaping (T)->(ElementType)->Void,
                                 error errClassFunc: ((T)->(Error)->Void)? = nil,
        bag: DisposeBag) {
        
        self.subscribe(onSuccess: { [weak instance] args in
            guard let instance = instance else { return }
            let instanceFunction = classFunc(instance)
            instanceFunction(args)
            }, onError:  { [weak instance] error in
            guard let instance = instance, let errClassFunc = errClassFunc else { return }
            let instanceFunction = errClassFunc(instance)
            instanceFunction(error)
        }).disposed(by: bag)
    }
}

public extension ObservableType {

    func onlyOnce() -> Observable<Self.E> {
        return self.take(1)
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in ()}
    }

    func binds<O>(bag: DisposeBag, to observer: O...) where O: ObserverType, Self.E == O.E {
        let shared = self.share()
        observer.forEach { shared.bind(to: $0).disposed(by: bag) }
    }

    /**
     Добавляет в observable объект как weak ссылку, когда произойдет событие будет проверка что объект доступен иначе вернется .empty()
     */
    func guardWeak<WeakObj: AnyObject>(_ weakObj: WeakObj) -> Observable<(WeakObj, Self.E)> {
        return self.flatMap({ [weak weakObj] (obj) -> Observable<(WeakObj, Self.E)> in
            guard let weakObj = weakObj else { return Observable.empty() }
            return Observable.just((weakObj, obj))
        })
    }

    func map<T: AnyObject, Res>(_ instance: T, with classFunc: @escaping (T)->(Self.E)->(Res)) -> Observable<Res> {
        return self.flatMap { [weak instance] args -> Observable<Res> in
            guard let instance = instance else { return Observable.empty() }
            let instanceFunction = classFunc(instance)
            return Observable.just(instanceFunction(args))
        }
    }

    func filter<T: AnyObject>(_ instance: T, with classFunc: @escaping (T) -> () -> (Bool)) -> Observable<Self.E> {
        return self.filter { [weak instance] _  in
            guard let instance = instance else { return false}
            let instanceFunction = classFunc(instance)
            return instanceFunction()
        }
    }

    func subscribeNext(_ handler: @escaping (Self.E) -> Void) -> Disposable {
        return self.subscribe(onNext: handler)
    }

    func subscribeNextOnMain<T: AnyObject>(_ instance: T, with classFunc: @escaping (T)->(Self.E)->Void, bag: DisposeBag) {
        self.observeOn(MainScheduler.asyncInstance)
            .subscribeNext(instance, with: classFunc, bag: bag)
    }
    
    func subscribeNext<T: AnyObject>(_ instance: T, with classFunc: @escaping (T)->(Self.E)->Void, bag: DisposeBag) {
         self.subscribe(onNext: { [weak instance] args in
            guard let instance = instance else { return }
            let instanceFunction = classFunc(instance)
            instanceFunction(args)
         }).disposed(by: bag)
    }

    func subscribeNext<T: AnyObject>(_ instance: T, do classFunc: @escaping (T) -> () -> Void, bag: DisposeBag) {
        self.subscribe(onNext: { [weak instance] _ in
            guard let instance = instance else { return }
            let instanceFunction = classFunc(instance)
            instanceFunction()
        }).disposed(by: bag)
    }

    func doNext<T: AnyObject>(_ instance: T, with classFunc: @escaping (T)->(Self.E)->Void) -> Observable<Self.E> {
        return self.do(onNext: { [weak instance] args in
            guard let instance = instance else { return }
            let instanceFunction = classFunc(instance)
            instanceFunction(args)
        })
    }

    func doNext<T: AnyObject>(_ instance: T, do classFunc: @escaping (T) -> () -> Void) -> Observable<Self.E> {
        return  self.do(onNext: { [weak instance] _ in
            guard let instance = instance else { return }
            let instanceFunction = classFunc(instance)
            instanceFunction()
        })
    }

    func filter(_ val: Variable<Bool>) -> Observable<E> {
        return filter { _ in val.value }
    }

    func doOnError<T: AnyObject>(_ instance: T, _ classFunc: @escaping (T) -> (Error) -> Void) -> Observable<E> {
        return self.do(onError: { [unowned instance] err in
            let instanceFunction = classFunc(instance)
            instanceFunction(err)
        })
    }
}

public extension ObservableType {

    func endEditingOnNext<T: UIViewController>(_ instance: T) -> Observable<E> {
        return self.do(onNext: { [weak instance] _ in
            guard let instance = instance else { return }
            instance.view.endEditing(true)
        })
    }
}

public typealias Seconds = Int

public extension ObservableType where E == Seconds {
   func intervalMapLatest() -> Observable<Int64> {
         return flatMapLatest ({ seconds in
            Observable<Int64>
                .interval(RxTimeInterval(seconds), scheduler: MainScheduler.instance)
                .startWith(0)})
    }
}

public extension ObservableType {
    // swiftlint:disable all
    func flatMapCatchError<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O,
                                                           doOnNext: @escaping (O.E) -> Void = { _ in },
                                                          doOnError:  @escaping (Error) -> Void = { _ in })
        -> Observable<O.E> {
            return self.flatMap({ (val) -> Observable<O.E> in
                return try selector(val).asObservable().catchError({ error ->  Observable<O.E> in
                    doOnError(error)
                    return Observable.empty()
                })
            }).do(onNext: doOnNext)
    }

    func flatMapFirstCatchError<O>(_ selector: @escaping (Self.E) throws -> O,
                                   doOnNext: @escaping (O.E) -> Void = { _ in },
                                   doOnError:  @escaping (Error) -> Void = { _ in }) -> RxSwift.Observable<O.E> where O: ObservableConvertibleType {

        return self.flatMapFirst({ (val) -> Observable<O.E> in
            return try selector(val).asObservable().catchError({ error ->  Observable<O.E> in
                doOnError(error)
                return Observable.empty()
            })
        }).do(onNext: doOnNext)
    }
}
