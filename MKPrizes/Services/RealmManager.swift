//
//  RealmManager.swift
//  MKPrizes
//
//  Created by Mykola Korotun on 12.06.2021.
//

import Foundation
import RealmSwift

class RealmManager {

    private var realm = try! Realm()

    func observeUpdateChanges<T: Object>(type: T.Type,
                                         _ changeBlock: @escaping (RealmCollectionChange<Results<T>>) -> Void)
    -> NotificationToken? {

        do {
            let realm = try Realm()
            return realm.objects(type).observe({ (changes) in
                switch changes {
                case .update:
                    changeBlock(changes)
                default:
                    break
                }
            })
        } catch {
            return nil
        }
    }

    func fetchAll<T: Object>() -> [T] {
        Array(realm.objects(T.self))
    }

    func fetchAll<T: Object>(completion: @escaping ([T]) -> ()) {
        completion(fetchAll())

    }

    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
    }

    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            print(error)
        }
    }

    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }

}
